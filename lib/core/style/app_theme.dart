import 'package:flutter/material.dart';

class AppTheme {
  static String fontFamily(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar' ? 'Cairo' : 'Inter';
  static TextStyle body14(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.white,
    height: 1.65,
    fontFamily: fontFamily(context),
  );

  /// هذا الشكل اللي بدك ياه (نفس المثال تبعك)
  static TextStyle titleBold22(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppTheme.white,
    fontFamily: fontFamily(context),
  );

  /// (اختياري) ستايلات إضافية جاهزة
  static TextStyle body16(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.white,
    fontFamily: fontFamily(context),
  );

  static TextStyle sub12(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
    fontFamily: fontFamily(context),
  );
  static const Color blue = Color(0xFF3EA8EA);
  static const Color background = Color(0xff181818);
  // static const Color background = Color(0xFF2F2F2F); old old
  static const Color primary = Color(0xff0A9A57);
  static const Color secondary = Color(0xFFC00000);
  static const Color grey = Color(0xFFFAFAFA);
  static const Color greyHint = Color(0xFF9B9B9B);
  static const Color greyBorder = Color(0xFFE5E5E5);
  static const Color green = Color(0xff0A9A57);
  static const Color black = Color(0xFF000000);
  static const Color yellow = Color(0xFFF2E665);
  static const Color orange = Color(0xFFFFA047);
  static const Color greyHintNew = Color(0xFFCFCFCF);
  static const Color red = Color(0xFFF95B5B);
  static const Color white = Color(0xffFFFFFF);
  static const Color light = Color(0xffF2F2F2);
  static const Color gry = Color(0xffCFCFCF);
  static const Color LightActive = Color(0xff757575);
  static const Color Dark = Color(0xff181818);
  static const Color backfilter = Color(0xff3D3D3D);
  static const Color grye = Color(0xffaaaaaa);

  static ColorScheme colorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    secondary: secondary,
    surface: white,
    error: red,
    onPrimary: white,
    onSecondary: white,
    onSurface: secondary,
    onError: white,
  );

  // ================= THEME DATA ================= //

  static ThemeData get theme {
    return ThemeData(
      colorScheme: colorScheme,

      // Global font override → Tajawal
      fontFamily: 'Tajawal',

      scaffoldBackgroundColor: background,

      // ---------------- AppBar ---------------- //
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
        ),
      ),

      // ---------------- Icons ---------------- //
      iconTheme: const IconThemeData(color: secondary),

      // ---------------- Elevated Button ---------------- //
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: white,
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
      ),

      // ---------------- TextButton ---------------- //
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
          ),
        ),
      ),

      // ---------------- OutlinedButton ---------------- //
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
          ),
        ),
      ),

      // ---------------- Checkbox ---------------- //
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected) ? primary : white;
        }),
        checkColor: MaterialStateProperty.all(white),
      ),

      // ---------------- Divider ---------------- //
      dividerColor: grey,

      // ---------------- Input Fields ---------------- //
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey, // 👈 NEW grey background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        hintStyle: TextStyle(
          color: secondary.withOpacity(0.5),
          fontFamily: 'Tajawal',
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: secondary.withOpacity(0.8),
          fontFamily: 'Tajawal',
        ),
        errorStyle: const TextStyle(fontSize: 14, color: red),
      ),

      // ---------------- Bottom Navigation ---------------- //
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primary,
        unselectedItemColor: secondary.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'Tajawal',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Tajawal',
        ),
      ),

      // ---------------- Dialog ---------------- //
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primary,
          fontFamily: 'Tajawal',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: secondary,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }
}
