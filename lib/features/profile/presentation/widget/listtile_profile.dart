import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:breez_food_driver/core/widgets/custom_sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ListtileProfile extends StatelessWidget {
  final IconData? iconData; // Nullable
  final String? svgPath; // Nullable
  final String title;
  final void Function()? onTap;

  const ListtileProfile({
    super.key,
    this.iconData, // يا أيقونة
    this.svgPath, // يا SVG
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppTheme.Dark,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.LightActive, width: 1.w),
          ),
          child: svgPath != null
              ? SvgPicture.asset(
                  svgPath!,
                  width: 17.sp,
                  height: 17.sp,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.white,
                    BlendMode.srcIn,
                  ),
                )
              : Icon(iconData, size: 18.sp, color: AppTheme.white),
        ),
        title: CustomSubTitle(
          subtitle: title,
          color: AppTheme.white,
          fontsize: 14.sp,
        ),
        trailing: Icon(Icons.chevron_right, size: 22.sp, color: AppTheme.white),
      ),
    );
  }
}
