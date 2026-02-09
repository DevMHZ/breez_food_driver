import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPadding {
  AppPadding._();

  static EdgeInsets page(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h);
  }

  static const EdgeInsets small = EdgeInsets.all(8);
  static const EdgeInsets medium = EdgeInsets.all(16);
  static const EdgeInsets large = EdgeInsets.all(24);
}
