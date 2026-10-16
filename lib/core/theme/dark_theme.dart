import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// HEMI TON Dark Theme
/// PURE BLACK (#000000) Background, vibrant Pink (#FF1493) & Purple (#8A2BE2) accents.
class DarkTheme {
  DarkTheme._();

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.standard,
    primaryColor: AppColors.pink,
    scaffoldBackgroundColor: AppColors.black, // Pure Black (#000000)
    canvasColor: AppColors.black,
    splashFactory: InkSparkle.splashFactory,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.pink,
      onPrimary: Colors.white,
      primaryContainer: AppColors.purple,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.purple,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.cardBlack,
      onSecondaryContainer: AppColors.neonPink,
      tertiary: AppColors.blue,
      onTertiary: Colors.white,
      surface: AppColors.cardBlack,
      onSurface: AppColors.primaryText,
      surfaceContainer: AppColors.softBlack,
      surfaceContainerHigh: AppColors.softBlack,
      surfaceContainerHighest: AppColors.softBlack,
      surfaceContainerLow: AppColors.cardBlack,
      surfaceContainerLowest: AppColors.black,
      onSurfaceVariant: AppColors.secondaryText,
      outline: AppColors.borderDarkNavy,
      outlineVariant: AppColors.borderDarkNavy,
      error: AppColors.error,
      onError: AppColors.white,
      shadow: Colors.black,
    ),
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: AppColors.cardBlack,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderDarkNavy, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black, // Pure Black
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: AppColors.pink),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.black, // Pure Black
      selectedItemColor: AppColors.pink,
      unselectedItemColor: AppColors.mutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBlack,
      hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
      prefixIconColor: AppColors.mutedText,
      suffixIconColor: AppColors.mutedText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderDarkNavy, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderDarkNavy, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.pink, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.pink,
      selectionColor: Color(0x40FF1493),
      selectionHandleColor: AppColors.pink,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardBlack,
      elevation: 10,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.borderDarkNavy, width: 1),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.black,
      modalBackgroundColor: AppColors.black,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        side: BorderSide(color: AppColors.borderDarkNavy, width: 1),
      ),
      dragHandleColor: AppColors.pink,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDarkNavy,
      thickness: 1,
    ),
    dividerColor: AppColors.borderDarkNavy,
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.pink,
      unselectedLabelColor: AppColors.secondaryText,
      indicatorColor: AppColors.pink,
      dividerColor: AppColors.transparent,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.softBlack,
      selectedColor: AppColors.pink.withValues(alpha: 0.2),
      side: const BorderSide(color: AppColors.borderDarkNavy),
      labelStyle: const TextStyle(color: AppColors.secondaryText),
      secondaryLabelStyle: const TextStyle(color: AppColors.pink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.white : AppColors.mutedText),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.pink : AppColors.softBlack),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.pink : AppColors.borderDarkNavy),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.pink,
      inactiveTrackColor: AppColors.softBlack,
      thumbColor: AppColors.pink,
      overlayColor: AppColors.pink.withValues(alpha: 0.2),
      trackHeight: 4,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.pink : AppColors.softBlack),
      checkColor: WidgetStateProperty.all(AppColors.white),
      side: const BorderSide(color: AppColors.borderDarkNavy),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.pink : AppColors.mutedText),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.pink,
      linearTrackColor: AppColors.softBlack,
      circularTrackColor: AppColors.softBlack,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardBlack,
      contentTextStyle: const TextStyle(color: AppColors.primaryText),
      actionTextColor: AppColors.pink,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderDarkNavy),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.primaryText,
      iconColor: AppColors.pink,
      subtitleTextStyle: TextStyle(color: AppColors.secondaryText),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.cardBlack,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDarkNavy),
      ),
      textStyle: const TextStyle(color: AppColors.primaryText, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.pink,
        side: const BorderSide(color: AppColors.pink, width: 1.2),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.pink,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.pink,
      foregroundColor: Colors.white,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDarkNavy),
      ),
      textStyle: const TextStyle(color: AppColors.primaryText, fontSize: 12),
    ),
    splashColor: AppColors.pink.withValues(alpha: 0.12),
    highlightColor: AppColors.purple.withValues(alpha: 0.08),
    hoverColor: AppColors.pink.withValues(alpha: 0.08),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.4),
        displayMedium: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        displaySmall: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.2),
        headlineLarge: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.3),
        headlineMedium: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        headlineSmall: TextStyle(fontSize: 14.5, color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 15.5, color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 13.5, color: AppColors.primaryText, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 12.5, color: AppColors.primaryText, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 13.5, color: AppColors.primaryText, height: 1.3),
        bodyMedium: TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.3),
        bodySmall: TextStyle(fontSize: 10.5, color: AppColors.mutedText, height: 1.2),
        labelLarge: TextStyle(fontSize: 12.5, color: AppColors.pink, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 9.5, color: AppColors.mutedText),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
