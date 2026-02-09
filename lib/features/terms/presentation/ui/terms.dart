import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:breez_food_driver/core/di/di.dart';
import 'package:breez_food_driver/core/widgets/custom_appbar_profile.dart';
import 'package:breez_food_driver/features/terms/presentation/cubit/terms_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  late final TermsCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<TermsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.load());
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TermsCubit, TermsState>(
      bloc: cubit,
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              automaticallyImplyLeading: false,
              toolbarHeight: 60.h,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CustomAppbarProfile(
                  icon: Icons.arrow_back_ios,
                  ontap: () => Navigator.pop(context),
                  title: "الشروط والأحكام".tr(),

                  backgroundcolor: Colors.transparent,
                ),
              ),
            ),

            body: state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (msg) => Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13.sp,
                      fontFamily: AppTheme.fontFamily(context),
                    ),
                  ),
                ),
              ),
              loaded: (data) {
                final locale = context.locale.languageCode;
                final text = data
                    .byLocale(locale)
                    .replaceAll('\r\n', '\n')
                    .trim();

                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              text.isEmpty ? "—" : text,
                              style: AppTheme.body14(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
