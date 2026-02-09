import 'dart:developer';
import 'package:breez_food_driver/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'labbridge_high_importance',
    'LabBridge Notifications',
    description: 'Important notifications for doctors',
    importance: Importance.high,
  );

  /// ============================================================
  /// INITIALIZE
  /// ============================================================
  static Future<void> init({bool skipFirebaseInit = false}) async {
    // ✅ خلي Firebase.init بالـ main فقط
    if (!skipFirebaseInit) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await _initLocal();
    await _initFCM();

    log("🔔 AppNotificationService initialized ✅");
  }

  /// ============================================================
  /// LOCAL NOTIFICATIONS
  /// ============================================================
  static Future<void> _initLocal() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload);
      },
    );

    final androidImpl = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(_channel);
  }

  /// ============================================================
  /// FIREBASE MESSAGING
  /// ============================================================
  static Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, sound: true, badge: true);

    // ✅ TOKEN: لازم try/catch حتى ما يوقع التطبيق
    try {
      final token = await messaging.getToken();
      log("📲 FCM TOKEN: $token");
    } catch (e, st) {
      log("🟧 getToken failed (ignored): $e");
      log("$st");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      log("🔄 NEW TOKEN: $t");
      // TODO: Save to server
    });

    // FOREGROUND handler
    FirebaseMessaging.onMessage.listen((message) {
      log("📩 Foreground message: ${message.notification?.title}");
      _showLocal(message);
    });

    // ✅ مهم جداً: لا تسجل onBackgroundMessage هون نهائياً
    // FirebaseMessaging.onBackgroundMessage(...) => لازم يكون بالـ main فقط
  }

  /// ============================================================
  /// SHOW LOCAL NOTIFICATION
  /// ============================================================
  static Future<void> _showLocal(RemoteMessage msg) async {
    final notification = msg.notification;
    if (notification == null) return;

    await _local.show(
      msg.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: msg.data.isNotEmpty ? msg.data.toString() : null,
    );
  }

  static void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    try {
      log("🧩 Local Tap: $payload");
    } catch (_) {}
  }
}

class FCMTokenService {
  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}
