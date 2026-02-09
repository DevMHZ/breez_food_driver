import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnlineToggleButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onPressed;

  const OnlineToggleButton({
    super.key,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.w,
      height: 56.w,
      child: FloatingActionButton(
        backgroundColor: AppTheme.Dark,
        onPressed: isBusy
            ? null
            : () {
                debugPrint("BTN CLICKED");
                onPressed?.call();
              },

        child: isBusy
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset('assets/b_driver/onboarding.png', height: 30.h),
      ),
    );
  }
}
