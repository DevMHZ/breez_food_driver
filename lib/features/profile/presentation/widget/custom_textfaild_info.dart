import 'package:breez_food_driver/core/style/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextfaildInfo extends StatelessWidget {
  final String label; // هاد صار عنوان فوق
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool readOnly;

  const CustomTextfaildInfo({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    required this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10.r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ التيسكت فوق
        Padding(
          padding: EdgeInsetsDirectional.only(start: 2.w, bottom: 6.h),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.90), // واضح عالأسود
              fontSize: 13.sp,
              fontFamily: "Cairo",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: AppTheme.primary,
              selectionColor: Color(0x3322C55E),
              selectionHandleColor: AppTheme.primary,
            ),
          ),
          child: TextFormField(
            keyboardType: keyboardType,
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontFamily: "Cairo",
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              // ❌ بدون labelText نهائياً
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13.sp,
                fontFamily: "Cairo",
              ),

              filled: true,
              fillColor: const Color(0xFFF7F7F7),

              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.18),
                  width: 1,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
