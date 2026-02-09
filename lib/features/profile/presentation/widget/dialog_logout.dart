
import 'package:breez_food_driver/core/di/di.dart' show getIt;
import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:breez_food_driver/core/widgets/custom_sub_title.dart';
import 'package:breez_food_driver/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breez_food_driver/features/auth/presentation/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showLogoutDialog(BuildContext context) {
  final cubit = getIt<AuthFlowCubit>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      return BlocListener<AuthFlowCubit, AuthFlowState>(
        bloc: cubit,
        listener: (ctx, state) {
          state.whenOrNull(
            loading: () => EasyLoading.show(status: "Logging out..."),
            error: (msg) {
              EasyLoading.dismiss();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: CustomSubTitle(
                    subtitle: msg,
                    color: AppTheme.white,
                    fontsize: 12.sp,
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            loggedOut: (msg) {
              EasyLoading.dismiss();

              Navigator.pop(dialogCtx);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
                (_) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: CustomSubTitle(
                    subtitle: msg,
                    color: AppTheme.white,
                    fontsize: 12.sp,
                  ),
                  backgroundColor: AppTheme.primary ,
                ),
              );
            },
          );
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppTheme.Dark,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/icons/logout.svg",
                  width: 35.sp,
                  height: 35.sp,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 12),
                CustomSubTitle(
                  subtitle: "Do you want logout?",
                  color: AppTheme.white,
                  fontsize: 14.sp,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.w,
                          vertical: 25.h,
                        ),
                        backgroundColor: AppTheme.black,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                      ),
                      onPressed: () {
                        cubit.logout();
                      },
                      child: CustomSubTitle(
                        subtitle: "Yes",
                        color: AppTheme.white,
                        fontsize: 14.sp,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.w,
                          vertical: 25.h,
                        ),
                        backgroundColor: AppTheme.primary ,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: CustomSubTitle(
                        subtitle: "Cancel",
                        color: AppTheme.white,
                        fontsize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
