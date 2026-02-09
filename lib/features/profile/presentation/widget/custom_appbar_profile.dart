import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppbarProfile extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final VoidCallback ontap;

  const CustomAppbarProfile({
    super.key,
    this.icon,
    this.title,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 30),
      child: SizedBox(
        height: 48.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (icon != null)
              PositionedDirectional(
                start: 0,
                child: GestureDetector(
                  onTap: ontap,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.LightActive, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 6),
                      child: Icon(icon, color: AppTheme.white, size: 16.sp),
                    ),
                  ),
                ),
              ),

            if (title != null)
              Center(
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
