import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// HEMI TON Dark Theme
/// Dark Navy surfaces, vibrant pink & purple accents, crisp white text.
class DarkTheme {
  DarkTheme._();

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.dark,
    visualDensity: VisualDensity.standard,
    primaryColor: AppColors.pink,
    scaffoldBackgroundColor: AppColors.darkNavy,
    canvasColor: AppColors.darkNavy,
    splashFactory: InkSparkle.splashFactory,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.pink,
      onPrimary: Colors.white,
      primaryContainer: AppColors.purple,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.purple,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.cardNavy,
      onSecondaryContainer: AppColors.neonPink,
      tertiary: AppColors.blue,
      onTertiary: Colors.white,
      surface: AppColors.cardNavy,
      onSurface: AppColors.primaryText,
      surfaceContainer: AppColors.softNavy,
      surfaceContainerHigh: AppColors.softNavy,
      surfaceContainerHighest: AppColors.softNavy,
      surfaceContainerLow: AppColors.cardNavy,
      surfaceContainerLowest: AppColors.darkNavy,
      onSurfaceVariant: AppColors.secondaryText,
      outline: AppColors.borderNavy,
      outlineVariant: AppColors.borderNavy,
      error: AppColors.error,
      onError: AppColors.white,
      shadow: Colors.black,
    ),
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: AppColors.cardNavy,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderNavy, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkNavy,
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
      backgroundColor: AppColors.darkNavy,
      selectedItemColor: AppColors.pink,
      unselectedItemColor: AppColors.mutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardNavy,
      hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
      prefixIconColor: AppColors.mutedText,
      suffixIconColor: AppColors.mutedText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderNavy, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderNavy, width: 1),
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
      backgroundColor: AppColors.cardNavy,
      elevation: 10,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.borderNavy, width: 1),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkNavy,
      modalBackgroundColor: AppColors.darkNavy,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        side: BorderSide(color: AppColors.borderNavy, width: 1),
      ),
      dragHandleColor: AppColors.pink,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderNavy,
      thickness: 1,
    ),
    dividerColor: AppColors.borderNavy,
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.pink,
      unselectedLabelColor: AppColors.secondaryText,
      indicatorColor: AppColors.pink,
      dividerColor: AppColors.transparent,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.softNavy,
      selectedColor: AppColors.pink.withValues(alpha: 0.2),
      side: const BorderSide(color: AppColors.borderNavy),
      labelStyle: const TextStyle(color: AppColors.secondaryText),
      secondaryLabelStyle: const TextStyle(color: AppColors.pink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.white : AppColors.mutedText),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.pink : AppColors.softNavy),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.pink : AppColors.borderNavy),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.pink,
      inactiveTrackColor: AppColors.softNavy,
      thumbColor: AppColors.pink,
      overlayColor: AppColors.pink.withValues(alpha: 0.2),
      trackHeight: 4,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.pink : AppColors.softNavy),
      checkColor: WidgetStateProperty.all(AppColors.white),
      side: const BorderSide(color: AppColors.borderNavy),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.pink : AppColors.mutedText),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.pink,
      linearTrackColor: AppColors.softNavy,
      circularTrackColor: AppColors.softNavy,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardNavy,
      contentTextStyle: const TextStyle(color: AppColors.primaryText),
      actionTextColor: AppColors.pink,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderNavy),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.primaryText,
      iconColor: AppColors.pink,
      subtitleTextStyle: TextStyle(color: AppColors.secondaryText),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.cardNavy,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderNavy),
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
        color: AppColors.cardNavy,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderNavy),
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
