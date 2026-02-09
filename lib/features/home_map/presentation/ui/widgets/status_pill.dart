import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final TextStyle textStyle;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final Color iconColor;

  const StatusPill({
    super.key,
    required this.text,
    required this.color,
    required this.textStyle,
    required this.width,
    required this.height,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isDisabled || onTap == null;

    return Opacity(
      opacity: disabled ? .55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(height / 2),
        onTap: disabled ? null : onTap,
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.22),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
                SizedBox(width: 10.w),
              ] else if (icon != null) ...[
                Icon(icon, color: iconColor, size: 18.sp),
                SizedBox(width: 10.w),
              ],
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
