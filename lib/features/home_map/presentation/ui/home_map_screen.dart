// ==============================
// HomeMapScreen.dart (FULL CODE)
// ==============================
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:breez_food_driver/core/di/di.dart';
import 'package:breez_food_driver/core/services/map_marker_icon.dart';
import 'package:breez_food_driver/core/services/shared_perfrences_key.dart';
import 'package:breez_food_driver/core/widgets/drawer.dart';
import 'package:breez_food_driver/features/driver_location/presentation/cubit/driver_location_cubit.dart';
import 'package:breez_food_driver/features/driver_status/presentation/cubit/driver_status_cubit.dart';
import 'package:breez_food_driver/features/home_map/presentation/ui/widgets/home_realtime_controller.dart';
import 'package:breez_food_driver/features/home_map/presentation/ui/widgets/internet_badge.dart';
import 'package:breez_food_driver/features/home_map/presentation/ui/widgets/offer_panel.dart';
import 'package:breez_food_driver/features/offers/presentation/cubit/offers_cubit.dart';
import 'package:breez_food_driver/features/orders/presentation/cubit/orders_cubit.dart'
    show OrderStatusCubit;
import 'package:breez_food_driver/features/orders/presentation/ui/order_details_dialog.dart';
import 'package:breez_food_driver/features/orders/presentation/ui/order_tracking_screen.dart';
import 'package:breez_food_driver/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'widgets/home_body_stack.dart';
import 'widgets/offer_listener.dart';

enum DriverStatus { offline, searching, offerReceived }

const String general_url = 'https://breezefood.cloud/api';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen>
    with WidgetsBindingObserver {
  // -------------------- Audio
  bool _realtimeConnected = false;
  DriverLocationCubit? _locationCubit;
  DriverStatusCubit? _driverStatusCubit;
  OfferCubit? _offerCubit;
  OrderStatusCubit? _orderStatusCubit;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locationCubit ??= context.read<DriverLocationCubit>();
    _driverStatusCubit ??= context.read<DriverStatusCubit>();
    _offerCubit ??= context.read<OfferCubit>();
    _orderStatusCubit ??= context.read<OrderStatusCubit>();
  }

  StreamSubscription<InternetStatus>? _internetSub;
  StreamSubscription<List<ConnectivityResult>>? _netSub;

  bool _hasInternet = true;

  Future<void> _initInternetWatcher() async {
    _hasInternet = await InternetConnection().hasInternetAccess;
    if (mounted) setState(() {});

    _internetSub?.cancel();
    _internetSub = InternetConnection().onStatusChange.distinct().listen((
      status,
    ) {
      final ok = status == InternetStatus.connected;
      if (!mounted) return;
      if (ok == _hasInternet) return;
      setState(() => _hasInternet = ok);
    });

    _netSub?.cancel();
    _netSub = Connectivity().onConnectivityChanged.listen((_) {});
  }

  Future<void> _disposeInternetWatcher() async {
    await _internetSub?.cancel();
    await _netSub?.cancel();
    _internetSub = null;
    _netSub = null;
  }

  final AudioPlayer _offerPlayer = AudioPlayer();
  bool _offerSoundPlaying = false;

  Future<void> _initOfferAudio() async {
    try {
      await _offerPlayer.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            usageType: AndroidUsageType.notificationRingtone,
            contentType: AndroidContentType.sonification,
            audioFocus: AndroidAudioFocus.gainTransient,
            stayAwake: true,
            isSpeakerphoneOn: true,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
    } catch (e) {
      _log("❌ init audio context failed: $e");
    }
  }

  Future<void> startOfferSound() async {
    if (_offerSoundPlaying) return;
    _offerSoundPlaying = true;

    try {
      _log("🔊 starting offer sound...");
      await _offerPlayer.setReleaseMode(ReleaseMode.loop);
      await _offerPlayer.setVolume(1.0);
      await _offerPlayer.play(AssetSource('sounds/offer_ringtone.mp3'));
      _log("✅ offer sound started");
    } catch (e) {
      _offerSoundPlaying = false;
      _log("❌ offer sound start failed: $e");
    }
  }

  Future<void> _stopOfferSound() async {
    if (!_offerSoundPlaying) return;
    _offerSoundPlaying = false;

    try {
      await _offerPlayer.stop();
    } catch (e) {
      _log("❌ offer sound stop failed: $e");
    }
  }

  // -------------------- UI/Map
  static const bool kVerboseLogs = true;
  static const Duration kLocationSendInterval = Duration(seconds: 15);

  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _customerIcon;
  BitmapDescriptor? _restaurantIcon;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(34.8021, 38.9968),
    zoom: 6.5,
  );

  late final HomeRealtimeController _realtime;

  bool _isOnline = false;
  bool _isChangingStatus = false;
  DriverStatus _driverStatus = DriverStatus.offline;

  StreamSubscription<Position>? _posSub;
  LatLng? _myLatLng;

  bool _followMe = true;
  bool _mapReady = false;

  DateTime _lastUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);
  LatLng? _lastCameraTarget;

  // Offer markers + offer data
  LatLng? _offerPickup;
  LatLng? _offerDropoff;
  Map<String, dynamic>? _currentOffer;
  bool _didFitOfferBounds = false;

  bool _showOfferSheet = false;
  bool _restoringActiveOrder = false;

  void _log(String msg) {
    if (!kVerboseLogs) return;
    // ignore: avoid_print
    print("🟦[HOME_MAP] $msg");
  }

  // -------------------- Icons
  Future<void> _loadMarkerIcons() async {
    try {
      _driverIcon = await MapMarkerIcon.fromAsset(
        "assets/b_driver/driver_map_point.png",
        width: 120,
      );
      _customerIcon = await MapMarkerIcon.fromAsset(
        "assets/b_driver/customer_map_point.png",
        width: 120,
      );
      _restaurantIcon = await MapMarkerIcon.fromAsset(
        "assets/b_driver/resturant_map_point.png",
        width: 120,
      );
      if (mounted) setState(() {});
    } catch (e) {
      _log("❌ Failed to load marker icons: $e");
    }
  }

  // -------------------- Lifecycle
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initOfferAudio();
    _loadMarkerIcons();
    _initInternetWatcher();

    _realtime = HomeRealtimeController(
      pusher: PusherChannelsFlutter.getInstance(),
      generalUrl: general_url,
      getDriverId: () async =>
          (await AuthStorageHelper.getUserId())?.toString(),
      getAuthToken: () async => await AuthStorageHelper.getToken(),
      onOffer: (offer) {
        if (!mounted) return;

        context.read<OfferCubit>().onOfferReceived(offer);

        try {
          final map = (offer as Map).cast<String, dynamic>();
          _onOfferArrived(map);
        } catch (e) {
          _log("offer cast failed: $e");
        }
      },
      onLog: (m) => _log(m),
      onConnectionChanged: (connected) {
        if (!mounted) return;
        setState(() => _realtimeConnected = connected);
      },
    );

    _bootstrap();
    _startLocationTracking();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _restoreActiveOrderIfAny();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _stopOfferSound();
    _offerPlayer.dispose();

    _stopLocationTracking();

    try {
      _locationCubit?.stop();
    } catch (_) {}

    _disposeInternetWatcher();

    _realtime.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restoreActiveOrderIfAny();
    }
  }

  Future<void> _bootstrap() async {
    final manualOffline =
        (await AuthStorageHelper.getFlag(AuthStorageHelper.manualOfflineKey)) ??
        false;

    setState(() {
      _isOnline = !manualOffline;
      _driverStatus = _isOnline ? DriverStatus.searching : DriverStatus.offline;
    });

    await _realtime.start(connectIfOnline: _isOnline);

    context.read<DriverLocationCubit>().setOnline(
      _isOnline,
      interval: kLocationSendInterval,
    );

    await _realtime.setOnline(_isOnline);
  }

  // -------------------- Local restore (NO SERVER CHECK)
  Future<void> _restoreActiveOrderIfAny() async {
    if (_restoringActiveOrder) return;
    _restoringActiveOrder = true;

    try {
      if (!mounted) return;

      if (_driverStatus == DriverStatus.offerReceived) return;
      if (_showOfferSheet) return;

      final activeOrderId = await AuthStorageHelper.getActiveOrderId();
      if (activeOrderId == null) return;

      final snap = await AuthStorageHelper.getActiveOrderSnapshot();
      final order = snap ?? <String, dynamic>{};

      _log("📌 Restoring active order locally: $activeOrderId");

      final statusCubit = context.read<OrderStatusCubit>();
      final locationCubit = context.read<DriverLocationCubit>();

      final delivered = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: statusCubit),
              BlocProvider.value(value: locationCubit),
            ],
            child: OrderTrackingScreen(orderId: activeOrderId, order: order),
          ),
        ),
      );

      if (delivered == true) {
        await AuthStorageHelper.clearActiveOrder();
        await _resetAfterOrderCompleted();
      }
    } finally {
      _restoringActiveOrder = false;
    }
  }

  // -------------------- Online toggle
  Future<void> _toggleOnline() async {
    if (_isChangingStatus) return;
    if (_driverStatus == DriverStatus.offerReceived) return;

    setState(() => _isChangingStatus = true);

    final cubit = context.read<DriverStatusCubit>();
    final newIsOnline = await cubit.toggle();

    if (!mounted) return;
    setState(() => _isChangingStatus = false);

    if (newIsOnline == null) {
      _log("TOGGLE ERROR");
      return;
    }

    await AuthStorageHelper.setFlag(
      AuthStorageHelper.manualOfflineKey,
      newIsOnline == false,
    );

    setState(() {
      _isOnline = newIsOnline;
      _driverStatus = _isOnline ? DriverStatus.searching : DriverStatus.offline;
    });

    context.read<DriverLocationCubit>().setOnline(
      _isOnline,
      interval: kLocationSendInterval,
    );

    await _realtime.setOnline(_isOnline);
  }

  Future<void> _forceOnline() async {
    if (_isChangingStatus) return;
    if (_isOnline) return;

    setState(() => _isChangingStatus = true);

    final cubit = context.read<DriverStatusCubit>();
    final newIsOnline = await cubit.setOnline(true, current: _isOnline);

    if (!mounted) return;
    setState(() => _isChangingStatus = false);

    if (newIsOnline != true) {
      _log("FORCE ONLINE FAILED");
      return;
    }

    setState(() {
      _isOnline = true;
      _driverStatus = DriverStatus.searching;
    });

    context.read<DriverLocationCubit>().setOnline(
      true,
      interval: kLocationSendInterval,
    );

    await _realtime.setOnline(true);
  }

  // -------------------- Location
  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) return false;
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<void> _startLocationTracking() async {
    final ok = await _ensureLocationPermission();
    if (!ok) {
      _log("Location permission/service not available");
      return;
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    await _posSub?.cancel();

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen((
      pos,
    ) async {
      final latLng = LatLng(pos.latitude, pos.longitude);
      _myLatLng = latLng;

      try {
        context.read<DriverLocationCubit>().setLatest(latLng);
      } catch (_) {}

      final now = DateTime.now();

      if (now.difference(_lastUiUpdate).inMilliseconds >= 800) {
        _lastUiUpdate = now;
        if (mounted) setState(() {});
      }

      final offerActive = _driverStatus == DriverStatus.offerReceived;

      if (_mapReady &&
          _followMe &&
          !offerActive &&
          _mapController.isCompleted) {
        if (now.difference(_lastCameraMove).inMilliseconds < 1800) return;

        if (_lastCameraTarget != null) {
          final dist = Geolocator.distanceBetween(
            _lastCameraTarget!.latitude,
            _lastCameraTarget!.longitude,
            latLng.latitude,
            latLng.longitude,
          );
          if (dist < 12) return;
        }

        _lastCameraMove = now;
        _lastCameraTarget = latLng;

        final controller = await _mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 16.5, tilt: 0, bearing: 0),
          ),
        );
      }
    }, onError: (e) => _log("Location stream error: $e"));
  }

  Future<void> _stopLocationTracking() async {
    await _posSub?.cancel();
    _posSub = null;
  }

  Future<void> _recenter() async {
    if (_myLatLng == null || !_mapController.isCompleted) return;

    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _myLatLng!, zoom: 16.5, tilt: 0, bearing: 0),
      ),
    );
    if (mounted) setState(() => _followMe = true);
  }

  // -------------------- Offer handling
  int? _extractOrderId(Map<String, dynamic> offer) {
    final order = (offer['order'] as Map?)?.cast<String, dynamic>() ?? {};
    final raw = order['id'];
    if (raw is num) return raw.toInt();
    return int.tryParse("$raw");
  }

  void _onOfferArrived(Map<String, dynamic> offer) {
    if (_showOfferSheet) return;

    _applyOfferMarkers(offer);

    setState(() {
      _currentOffer = offer;
      _showOfferSheet = true;
      _driverStatus = DriverStatus.offerReceived;
    });

    startOfferSound();
  }

  Future<void> _fitPickupDropoffBounds() async {
    if (!_mapReady || !_mapController.isCompleted) return;
    final p = _offerPickup;
    final d = _offerDropoff;
    if (p == null || d == null) return;

    final sw = LatLng(
      (p.latitude < d.latitude) ? p.latitude : d.latitude,
      (p.longitude < d.longitude) ? p.longitude : d.longitude,
    );
    final ne = LatLng(
      (p.latitude > d.latitude) ? p.latitude : d.latitude,
      (p.longitude > d.longitude) ? p.longitude : d.longitude,
    );

    final controller = await _mapController.future;
    await Future.delayed(const Duration(milliseconds: 120));
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: sw, northeast: ne),
        90,
      ),
    );
    _didFitOfferBounds = true;
  }

  void _applyOfferMarkers(Map<String, dynamic> offer) {
    final order = (offer['order'] as Map?)?.cast<String, dynamic>() ?? {};
    final pickup = (order['pickup'] as Map?)?.cast<String, dynamic>();
    final dropoff = (order['dropoff'] as Map?)?.cast<String, dynamic>();

    LatLng? p;
    LatLng? d;

    if (pickup != null) {
      final lat = pickup['lat'];
      final lng = pickup['lng'];
      if (lat is num && lng is num) {
        p = LatLng(lat.toDouble(), lng.toDouble());
      }
    }

    if (dropoff != null) {
      final lat = dropoff['lat'];
      final lng = dropoff['lng'];
      if (lat is num && lng is num) {
        d = LatLng(lat.toDouble(), lng.toDouble());
      }
    }

    if (!mounted) return;

    setState(() {
      _offerPickup = p;
      _offerDropoff = d;
      _followMe = false;
      _didFitOfferBounds = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitPickupDropoffBounds();
    });
  }

  // ✅ Accept: (مو شرط تعدّلها) بس هاي نسخة آمنة
  Future<void> _acceptOffer() async {
    final offer = _currentOffer;
    if (offer == null) return;

    await _stopOfferSound();

    if (!mounted) return;

    // سكّر UI فوراً
    setState(() => _showOfferSheet = false);

    final orderId = _extractOrderId(offer);
    if (orderId == null) {
      _log("❌ orderId null");
      return;
    }

    bool ok = false;
    try {
      ok = await context.read<OfferCubit>().acceptCurrent().timeout(
        const Duration(seconds: 8),
      );
    } catch (e) {
      _log("❌ acceptCurrent failed/timeout: $e");
      ok = false;
    }

    if (!ok || !mounted) {
      // رجّع الحالة
      setState(() {
        _currentOffer = null;
        _offerPickup = null;
        _offerDropoff = null;
        _didFitOfferBounds = false;
        _followMe = true;
        _driverStatus = _isOnline
            ? DriverStatus.searching
            : DriverStatus.offline;
      });
      return;
    }

    final statusCubit = context.read<OrderStatusCubit>();
    final locationCubit = context.read<DriverLocationCubit>();
    final order = (offer['order'] as Map).cast<String, dynamic>();

    await AuthStorageHelper.saveActiveOrder(
      orderId: orderId,
      orderSnapshot: order,
    );

    final delivered = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: statusCubit),
            BlocProvider.value(value: locationCubit),
          ],
          child: OrderTrackingScreen(orderId: orderId, order: order),
        ),
      ),
    );

    if (delivered == true && mounted) {
      await AuthStorageHelper.clearActiveOrder();
      await _resetAfterOrderCompleted();
    }
  }

  // ✅ Decline: هاي أهم نسخة (stop + close UI فوراً + decline async)
  Future<void> _declineOffer() async {
    await _stopOfferSound();
    if (!mounted) return;

    // سكّر UI فوراً (هذا اللي بيمنع الرنة تضل + يمنع crash UI)
    setState(() {
      _showOfferSheet = false;
      _currentOffer = null;
      _offerPickup = null;
      _offerDropoff = null;
      _didFitOfferBounds = false;
      _followMe = true;
      _driverStatus = _isOnline ? DriverStatus.searching : DriverStatus.offline;
    });

    // ابعت decline للسيرفر بدون ما نعلق الواجهة
    unawaited(() async {
      try {
        await context.read<OfferCubit>().declineCurrent().timeout(
          const Duration(seconds: 8),
        );
      } catch (e) {
        _log("❌ declineCurrent failed/timeout: $e");
      }
    }());
  }

  Future<void> _resetAfterOrderCompleted() async {
    await _stopOfferSound();

    setState(() {
      _showOfferSheet = false;
      _currentOffer = null;
      _offerPickup = null;
      _offerDropoff = null;
      _followMe = true;
      _didFitOfferBounds = false;
      _driverStatus = _isOnline ? DriverStatus.searching : DriverStatus.offline;
    });

    final manualOffline =
        (await AuthStorageHelper.getFlag(AuthStorageHelper.manualOfflineKey)) ??
        false;

    if (!manualOffline) {
      await _forceOnline();
    }
  }

  String _restaurantName() {
    final order =
        (_currentOffer?['order'] as Map?)?.cast<String, dynamic>() ?? {};
    final rest = (order['restaurant'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = (rest['name'] ?? '').toString().trim();
    return name.isEmpty ? '-' : name;
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      if (_myLatLng != null)
        Marker(
          markerId: const MarkerId("driver"),
          position: _myLatLng!,
          icon:
              _driverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          zIndex: 999,
        ),
      if (_offerPickup != null)
        Marker(
          markerId: const MarkerId("pickup"),
          position: _offerPickup!,
          icon:
              _restaurantIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(
            title: "home.offer_map_pickup_title".tr(
              namedArgs: {"name": _restaurantName()},
            ),
          ),
          zIndex: 10,
        ),
      if (_offerDropoff != null)
        Marker(
          markerId: const MarkerId("dropoff"),
          position: _offerDropoff!,
          icon:
              _customerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          anchor: const Offset(0.5, 1.0),
          infoWindow: InfoWindow(title: "home.offer_map_dropoff_title".tr()),
          zIndex: 10,
        ),
    };

    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const CustomDrawer(),
        body: OfferListener(
          onOfferArrived: (offer) => _onOfferArrived(offer),
          child: Stack(
            children: [
              HomeBodyStack(
                scaffoldKey: _scaffoldKey,
                mapController: _mapController,
                initialCameraPosition: _initialCameraPosition,
                markers: markers,
                onRecenter: _recenter,
                onUserPan: () {
                  if (mounted) setState(() => _followMe = false);
                },
                followMe: _followMe,
                isOnline: _isOnline,
                hasOffer: _showOfferSheet && _currentOffer != null,
                isChangingStatus: _isChangingStatus,
                onToggleOnline: _toggleOnline,
                onTestSound: startOfferSound,
                isConnected: _hasInternet,
                isSearching: _realtimeConnected,
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Center(
                    child: InternetBadge(isConnected: _hasInternet),
                  ),
                ),
              ),

              if (_showOfferSheet && _currentOffer != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: SafeArea(
                    top: false,
                    child: OfferFixedPanel(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: OrderDetailsDialog(
                        offerData: _currentOffer!,
                        onAccept: _acceptOffer,
                        onDecline: _declineOffer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
