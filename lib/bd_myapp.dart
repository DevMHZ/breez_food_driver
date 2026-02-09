import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:breez_food_driver/core/router/navigation_key.dart';
import 'package:breez_food_driver/core/services/launch_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          navigatorKey: NavigationKey.navigatorKey,
          debugShowCheckedModeBanner: false,
          home: child ?? const LaunchScreen(),

          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,

          theme: ThemeData(
                fontFamily: "Cairo",
            scaffoldBackgroundColor: AppTheme.Dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primary,
              brightness: Brightness.dark,
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: AppTheme.primary,
              circularTrackColor: AppTheme.backfilter,
            ),
          ),
          builder: (context, widget) {
            final wrapped = MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget ?? const SizedBox.shrink(),
            );
            return EasyLoading.init()(context, wrapped);
          },
        );
      },
      child: const LaunchScreen(),
    );
  }
}
