import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// HEMI TON Light Theme
/// Pure White background, Dark Navy text (#00152E), Pink (#FF1493) and Purple (#8A2BE2) accents.
class LightTheme {
  LightTheme._();

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.light,
    primaryColor: AppColors.pink,
    scaffoldBackgroundColor: AppColors.white,
    canvasColor: AppColors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.pink,
      onPrimary: AppColors.white,
      primaryContainer: Color(0xFFFFE4F1),
      onPrimaryContainer: AppColors.pink,
      secondary: AppColors.purple,
      onSecondary: AppColors.white,
      tertiary: AppColors.blue,
      onTertiary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.darkNavy,
      surfaceContainer: AppColors.lightSurface,
      surfaceContainerHigh: AppColors.lightSurface,
      surfaceContainerHighest: AppColors.lightSurface,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
      error: AppColors.error,
      onError: AppColors.white,
      shadow: Color(0x1A00152E),
    ),
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.darkNavy,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkNavy),
      titleTextStyle: TextStyle(
        color: AppColors.darkNavy,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.pink,
      unselectedItemColor: AppColors.lightMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      hintStyle: const TextStyle(color: AppColors.lightMuted, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.pink, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.pink,
      selectionColor: Color(0x40FF1493),
      selectionHandleColor: AppColors.pink,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      elevation: 8,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.darkNavy,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      modalBackgroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        side: BorderSide(color: AppColors.lightBorder),
      ),
      dragHandleColor: AppColors.pink,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.pink,
      unselectedLabelColor: AppColors.lightTextSecondary,
      indicatorColor: AppColors.pink,
      dividerColor: AppColors.transparent,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedColor: Color(0xFFFFE4F1),
      side: const BorderSide(color: AppColors.lightBorder),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
      secondaryLabelStyle: const TextStyle(color: AppColors.pink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pink,
        foregroundColor: AppColors.white,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.pink,
        side: const BorderSide(color: AppColors.pink, width: 1.2),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.pink,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.darkNavy,
      iconColor: AppColors.pink,
      subtitleTextStyle: TextStyle(color: AppColors.lightTextSecondary),
    ),
    dividerColor: AppColors.lightBorder,
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 24, color: AppColors.darkNavy, fontWeight: FontWeight.bold, letterSpacing: -0.4),
        displayMedium: TextStyle(fontSize: 20, color: AppColors.darkNavy, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        displaySmall: TextStyle(fontSize: 17, color: AppColors.darkNavy, fontWeight: FontWeight.bold, letterSpacing: -0.2),
        headlineLarge: TextStyle(fontSize: 18, color: AppColors.darkNavy, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        headlineMedium: TextStyle(fontSize: 16, color: AppColors.darkNavy, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        headlineSmall: TextStyle(fontSize: 14.5, color: AppColors.darkNavy, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 15.5, color: AppColors.darkNavy, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 13.5, color: AppColors.darkNavy, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 12.5, color: AppColors.darkNavy, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 13.5, color: AppColors.darkNavy, height: 1.3),
        bodyMedium: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary, height: 1.3),
        bodySmall: TextStyle(fontSize: 10.5, color: AppColors.lightMuted, height: 1.2),
        labelLarge: TextStyle(fontSize: 12.5, color: AppColors.pink, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 9.5, color: AppColors.lightMuted),
      ),
    ),
  );
}
