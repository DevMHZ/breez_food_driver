import 'package:breez_food_driver/bd_myapp.dart';
import 'package:breez_food_driver/core/di/di.dart';
import 'package:breez_food_driver/core/services/app_notification_service.dart';
import 'package:breez_food_driver/core/widgets/loading.dart';
import 'package:breez_food_driver/firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  configEasyLoading();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await setupDi();

  await AppNotificationService.init(skipFirebaseInit: true);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}
