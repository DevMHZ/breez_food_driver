import 'package:breez_food_driver/core/di/di.dart';
import 'package:breez_food_driver/core/style/app_theme.dart' show AppTheme;
import 'package:breez_food_driver/core/widgets/custom_button.dart';
import 'package:breez_food_driver/core/widgets/custom_sub_title.dart';
import 'package:breez_food_driver/core/widgets/custom_title.dart';
import 'package:breez_food_driver/core/widgets/fancy_toast.dart';
import 'package:breez_food_driver/features/auth/presentation/cubit/auth_flow_cubit.dart';
import 'package:breez_food_driver/features/driver_location/presentation/cubit/driver_location_cubit.dart';
import 'package:breez_food_driver/features/driver_status/presentation/cubit/driver_status_cubit.dart';
import 'package:breez_food_driver/features/home_map/presentation/ui/home_map_screen.dart';
import 'package:breez_food_driver/features/offers/presentation/cubit/offers_cubit.dart';
import 'package:breez_food_driver/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AuthFlowCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = getIt<AuthFlowCubit>();
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  void _toast(String message, {bool success = true, String? title}) {
    if (!mounted) return;
    showFancyToast(context, message: message, success: success, title: title);
  }

  void _handleLogin() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _toast("auth.validation_error".tr(), success: false);
      return;
    }

    cubit.login(
      email: emailController.text.trim(),
      password: passController.text,
    );
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<DriverStatusCubit>(
              create: (_) => getIt<DriverStatusCubit>(),
            ),
            BlocProvider<OfferCubit>(create: (_) => getIt<OfferCubit>()),
            BlocProvider<DriverLocationCubit>(
              create: (_) => getIt<DriverLocationCubit>(),
            ),
            BlocProvider<OrderStatusCubit>(
              create: (_) => getIt<OrderStatusCubit>(),
            ),
          ],
          child: const HomeMapScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.primary,
      body: BlocListener<AuthFlowCubit, AuthFlowState>(
        bloc: cubit,
        listener: (context, state) {
          state.whenOrNull(
            loading: () => EasyLoading.show(status: "common.loading".tr()),
            error: (msg) {
              EasyLoading.dismiss();
              _toast(msg, success: false);
            },
            loggedIn: (data) {
              EasyLoading.dismiss();

              final msg = (data is Map)
                  ? (data["message"]?.toString() ?? "auth.login_success".tr())
                  : "auth.login_success".tr();

              _toast(msg, success: true);

              _goHome();
            },
          );
        },
        child: Stack(
          children: [
            Image.asset(
              "assets/images/top-view-burgers-with-cherry-tomatoes.png",
              width: double.infinity,
              height: 265.h,
              fit: BoxFit.cover,
              cacheWidth: 600,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 80.h),
                child: Image.asset(
                  "assets/images/breeze-food2.png",
                  width: 150.w,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 228.h,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.Dark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 32.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTitle(
                                    title: "auth.welcome_title".tr(),
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 2.h),
                                  CustomSubTitle(
                                    subtitle: "auth.welcome_subtitle".tr(),
                                    color: AppTheme.gry,
                                    fontsize: 12,
                                  ),
                                  SizedBox(height: 32.h),

                                  _CustomTextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    hintText: "auth.email".tr(),
                                    validator: (v) {
                                      final val = (v ?? '').trim();
                                      if (val.isEmpty) {
                                        return "auth.email_required".tr();
                                      }
                                      if (!val.contains('@')) {
                                        return "auth.email_invalid".tr();
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 14.h),

                                  _CustomTextFormField(
                                    controller: passController,
                                    keyboardType: TextInputType.visiblePassword,
                                    hintText: "auth.password".tr(),
                                    isPassword: true,
                                    validator: (v) {
                                      final val = (v ?? '');
                                      if (val.trim().isEmpty) {
                                        return "auth.password_required".tr();
                                      }
                                      if (val.length < 6) {
                                        return "auth.password_short".tr();
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: 24.h),
                                  CustomButton(
                                    title: "auth.continue".tr(),
                                    onPressed: _handleLogin,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;

  const _CustomTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
  });

  @override
  State<_CustomTextFormField> createState() => __CustomTextFormFieldState();
}

class __CustomTextFormFieldState extends State<_CustomTextFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(color: AppTheme.LightActive),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppTheme.gry,
          fontSize: 14.sp,
          fontFamily: 'Manrope',
        ),
        filled: true,
        fillColor: AppTheme.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 3.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.black,
                ),
              )
            : null,
      ),
    );
  }
}
