import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'package:breez_food_driver/core/services/pusher_constants.dart';

typedef OfferCallback = void Function(Map<String, dynamic> offer);
typedef LogCallback = void Function(String message);
typedef ConnectionCallback = void Function(bool connected);

class HomeRealtimeController {
  HomeRealtimeController({
    required this.pusher,
    required this.generalUrl,
    required this.getDriverId,
    required this.getAuthToken,
    required this.onOffer,
    required this.onLog,
    this.onConnectionChanged,
  });

  final PusherChannelsFlutter pusher;
  final String generalUrl;

  final Future<String?> Function() getDriverId;
  final Future<String?> Function() getAuthToken;

  final OfferCallback onOffer;
  final LogCallback onLog;

  final ConnectionCallback? onConnectionChanged;

  // ---------------------------------------------------------
  // State
  // ---------------------------------------------------------
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  String? _driverId;
  String? _authToken;

  bool _started = false;
  bool _online = false;

  bool _pusherInitialized = false;

  // قفل لمنع تكرار init/subscribe/connect مع بعض
  Future<void> _ensureChain = Future.value();

  // منع subscribe لنفس القناة
  final Set<String> _subscribedChannels = {};

  // حالة الاتصال للـ UI
  bool _pusherConnected = false;
  void _setPusherConnected(bool v) {
    if (_pusherConnected == v) return;
    _pusherConnected = v;
    onConnectionChanged?.call(v);
  }

  // ---------------------------------------------------------
  // Public API
  // ---------------------------------------------------------
  Future<void> start({bool connectIfOnline = true}) async {
    if (_started) return;
    _started = true;

    onLog("Realtime: start()");
    await _loadAuth();

    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final r = results.first;
      onLog("Realtime: connectivity => $r");

      if (r == ConnectivityResult.none) {
        _disconnectPusher("no internet");
      } else {
        if (_online) {
          _ensurePusherConnected(); // محمية بالقفل
        }
      }
    });

    if (connectIfOnline && _online) {
      await _ensurePusherConnected();
    }
  }

  Future<void> stop() async {
    if (!_started) return;
    onLog("Realtime: stop()");
    _started = false;

    await _connSub?.cancel();
    _connSub = null;

    _disconnectPusher("controller stop");
  }

  Future<void> setOnline(bool online) async {
    _online = online;
    onLog("Realtime: setOnline($_online)");

    if (!_started) return;

    if (_online) {
      await _ensurePusherConnected();
    } else {
      _disconnectPusher("driver offline");
    }
  }

  Future<void> reloadAuth() async {
    onLog("Realtime: reloadAuth()");
    await _loadAuth();

    if (_online && _started) {
      _disconnectPusher("auth changed");
      await _ensurePusherConnected();
    }
  }

  // ---------------------------------------------------------
  // Internals
  // ---------------------------------------------------------
  Future<void> _loadAuth() async {
    _driverId = await getDriverId();
    _authToken = await getAuthToken();
    onLog("Realtime: auth loaded driverId=$_driverId token=${_authToken != null}");
  }

  void _disconnectPusher(String reason) {
    onLog("Realtime: pusher disconnect ($reason)");

    // مهم: unsubscribe قبل disconnect حتى ما يضل ChannelManager حافظ القناة
    final chans = _subscribedChannels.toList();
    for (final ch in chans) {
      try {
        pusher.unsubscribe(channelName: ch);
      } catch (_) {}
    }
    _subscribedChannels.clear();

    try {
      pusher.disconnect();
    } catch (_) {}

    // لا تعيد init flag لصفر دائمًا — خلينا نسمح باستخدام نفس init
    // لكن إذا أنت مصرّ تعمل init من جديد، خليه true/false حسب تجربتك.
    // غالباً الأفضل نخلي init مرة واحدة فقط.
    _setPusherConnected(false);
  }

  Future<void> _ensurePusherConnected() {
    // سيريال: أي محاولة جديدة تنتظر اللي قبلها
    _ensureChain = _ensureChain.then((_) async {
      if (!_started) return;
      if (!_online) return;

      if (_driverId == null || _authToken == null) {
        onLog("Realtime: missing driverId/token");
        return;
      }

      final conn = await Connectivity().checkConnectivity();
      if (conn == ConnectivityResult.none) {
        onLog("Realtime: no internet now");
        return;
      }

      if (!_pusherInitialized) {
        await _initPusher();
      }

      // connect أولاً (أحياناً الـ plugin يحب هيك)
      try {
        await pusher.connect();
        onLog("Realtime: pusher.connect() called");
      } catch (e) {
        onLog("Realtime: connect EXCEPTION $e");
        return;
      }

      // ثم subscribe مرة واحدة
      await _subscribeDriverChannelOnce();
    }).catchError((e) {
      onLog("Realtime: ensureChain ERROR $e");
    });

    return _ensureChain;
  }

  Future<void> _initPusher() async {
    if (_pusherInitialized) return;

    final authUrl = "$generalUrl/broadcasting/auth";
    final channelName = "${PusherConstants.channelPrefix}$_driverId";

    onLog("Realtime: init pusher channel=$channelName auth=$authUrl");

    try {
      await pusher.init(
        apiKey: PusherConstants.key,
        cluster: PusherConstants.cluster,
        useTLS: true,
        authEndpoint: authUrl,

        onAuthorizer: (String ch, String socketId, dynamic options) async {
          onLog("Realtime: authorizer ch=$ch socket=$socketId");

          final dioClient = Dio();
          final res = await dioClient.post(
            authUrl,
            data: dio.FormData.fromMap({
              "channel_name": ch,
              "socket_id": socketId,
            }),
            options: Options(
              headers: {
                "Authorization": "Bearer $_authToken",
                "Accept": "application/json",
              },
              responseType: ResponseType.json,
            ),
          );

          onLog("Realtime: auth ok => ${res.data}");
          return res.data; // {auth: ...}
        },

        onConnectionStateChange: (current, previous) {
          onLog("Realtime: pusher state $previous -> $current");

          final cur = current.toString().toUpperCase();
          final connected = cur.contains("CONNECTED");
          _setPusherConnected(connected);

          // إذا انفصل، لا تعمل subscribe ثاني لحالك هون
          // خلي اللي برا (connectivity/online) يعيد ensure بشكل نظيف
        },

        onError: (message, code, error) {
          onLog("Realtime: pusher error $message | $code | $error");
        },

        onEvent: (event) {
          onLog("Realtime: raw event ${event.eventName} data=${event.data}");
        },
      );

      _pusherInitialized = true;
      onLog("Realtime: init OK");
    } catch (e) {
      onLog("Realtime: init EXCEPTION $e");
    }
  }

  Future<void> _subscribeDriverChannelOnce() async {
    final channelName = "${PusherConstants.channelPrefix}$_driverId";

    if (_subscribedChannels.contains(channelName)) {
      // already subscribed ✅
      return;
    }

    onLog("Realtime: subscribe => $channelName");

    try {
      await pusher.subscribe(
        channelName: channelName,
        onEvent: (dynamic event) {
          try {
            if (event is! PusherEvent) return;

            final name = event.eventName;
            final dataStr = event.data ?? "";

            if (name.startsWith("pusher:")) return;

            final trimmed = dataStr.trim();
            if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) {
              onLog("Realtime: event data not json => ignore");
              return;
            }

            final decoded = jsonDecode(trimmed);

            if (name == PusherConstants.orderOfferEvent) {
              final map = Map<String, dynamic>.from(decoded as Map);
              onLog("Realtime: OFFER RECEIVED => $map");
              onOffer(map);
            }
          } catch (e) {
            onLog("Realtime: event parse error $e");
          }
        },
      );

      _subscribedChannels.add(channelName);
      onLog("Realtime: subscribe OK");
    } catch (e) {
      // إذا صار Already subscribed بسبب الـ SDK نفسه، خزّنها عندنا وكمّل
      final s = e.toString();
      if (s.contains("Already subscribed")) {
        _subscribedChannels.add(channelName);
        onLog("Realtime: subscribe already existed -> marked as subscribed");
        return;
      }
      onLog("Realtime: subscribe EXCEPTION $e");
    }
  }
}
