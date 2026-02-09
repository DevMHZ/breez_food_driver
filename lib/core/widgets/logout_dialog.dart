import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onLogoutConfirmed;
  final VoidCallback onCancel;

  const LogoutDialog({
    super.key,
    required this.onLogoutConfirmed,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: _Content(onLogoutConfirmed: onLogoutConfirmed, onCancel: onCancel),
    );
  }
}

class _Content extends StatelessWidget {
  final VoidCallback onLogoutConfirmed;
  final VoidCallback onCancel;

  const _Content({required this.onLogoutConfirmed, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final font = 'Cairo';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 26.h),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔴 Icon
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              color: AppTheme.primary,
              size: 28.sp,
            ),
          ),

          SizedBox(height: 18.h),

          // 📝 Title
          Text(
            'تسجيل الخروج',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: font,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),

          SizedBox(height: 8.h),

          // 🧾 Subtitle
          Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج من التطبيق؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: font,
              fontSize: 14.sp,
              height: 1.6,
              color: AppTheme.white.withOpacity(0.75),
            ),
          ),

          SizedBox(height: 26.h),

          // 🔘 Buttons
          Row(
            children: [
              // Cancel
              Expanded(
                child: _SecondaryButton(title: 'إلغاء', onTap: onCancel),
              ),
              SizedBox(width: 12.w),

              // Logout
              Expanded(
                child: _PrimaryButton(
                  title: 'تسجيل الخروج',
                  onTap: onLogoutConfirmed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _PrimaryButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SecondaryButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.white,
          ),
        ),
      ),
    );
  }
}
