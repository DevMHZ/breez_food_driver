import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:breez_food_driver/core/style/app_theme.dart';

class InternetBadge extends StatelessWidget {
  final bool isConnected;
  const InternetBadge({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final subtitle = isConnected
        ? "متصل بالإنترنت"
        : "لا يوجد اتصال بالإنترنت";

    final dotColor = isConnected ? AppTheme.green : AppTheme.red;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: dotColor),
          SizedBox(width: 10.w),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.65),

              // ✅ نفس نظام الخط بكل التطبيق
              fontFamily: AppTheme.fontFamily(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
