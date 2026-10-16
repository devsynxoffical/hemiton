import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Design System — HEMI TON
///
/// Palette:
/// - Pink:            #FF1493 (Primary Accent / CTA / Selected Tab / Buttons)
/// - Purple:          #8A2BE2 (Secondary Accent / Gradients / Highlights)
/// - Blue:            #00BFFF (Electric Sky Blue / Chips / Badges)
/// - Dark Navy:       #00152E (Deep Navy Accent / High-contrast Light Text)
/// - White:           #FFFFFF (Light Mode Background & Crisp Contrast)
/// - Golden Yellow:   #FFD700 (Coins, VIP, Special Rewards)
/// - Neon Pink Glow:  #FF00FF (Glows, Neon Highlights, Live Pulse)
///
/// Mode Backgrounds:
/// - DARK MODE:  PURE BLACK (#000000)
/// - LIGHT MODE: PURE WHITE (#FFFFFF)
/// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  // =====================================================================
  // User's Exact Brand Palette
  // =====================================================================
  static const Color pink = Color(0xFFFF1493);
  static const Color purple = Color(0xFF8A2BE2);
  static const Color blue = Color(0xFF00BFFF);
  static const Color darkNavy = Color(0xFF00152E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldenYellow = Color(0xFFFFD700);
  static const Color neonPink = Color(0xFFFF00FF);

  // =====================================================================
  // Backgrounds & Surfaces:
  // Dark Mode  -> PURE BLACK (#000000)
  // Light Mode -> PURE WHITE (#FFFFFF)
  // =====================================================================
  static const Color black = Color(0xFF000000); // Pure Black (Dark Mode Background)
  static const Color darkBlack = Color(0xFF080808); // Near Black
  static const Color cardBlack = Color(0xFF111111); // Dark Card Surface
  static const Color softBlack = Color(0xFF181818); // Soft Dark Surface
  static const Color borderDarkNavy = Color(0xFF1E2330); // Subtle Dark Border

  // Light Mode Background & Surfaces
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure White (Light Mode Background)
  static const Color lightCard = Color(0xFFFFFFFF); // Pure White Card
  static const Color lightSurface = Color(0xFFF7F8FA); // Light Off-White Surface
  static const Color lightBorder = Color(0xFFE2E8F0); // Light Border
  static const Color lightTextPrimary = Color(0xFF00152E); // Dark Navy Text
  static const Color lightTextSecondary = Color(0xFF4A5568);
  static const Color lightMuted = Color(0xFF718096);

  // Surface aliases for backward compatibility
  static const Color champagne = lightBackground;
  static const Color champagneCard = lightCard;
  static const Color champagneSoft = lightSurface;

  // =====================================================================
  // Primary Accents (Pink / Purple / Blue / Neon Pink)
  // HEMI TON old gold/bronze mapped directly to HEMI TON palette
  // =====================================================================
  static const Color warmGold = pink; // Primary Pink (#FF1493)
  static const Color metallicGold = purple; // Purple (#8A2BE2)
  static const Color lightGold = neonPink; // Neon Pink (#FF00FF)
  static const Color deepBronze = blue; // Electric Sky Blue (#00BFFF)
  static const Color goldBorder = pink; // Pink border
  static const Color goldHighlight = neonPink; // Neon glow
  static const Color borderGold = borderDarkNavy;

  // =====================================================================
  // Text Colors
  // =====================================================================
  static const Color primaryText = Color(0xFFFFFFFF); // White on Black
  static const Color secondaryText = Color(0xFFB0B0B0); // Muted on Black
  static const Color mutedText = Color(0xFF757575);

  // =====================================================================
  // Status Colors
  // =====================================================================
  static const Color success = Color(0xFF10B981);
  static const Color liveGreen = Color(0xFF10B981);
  static const Color liveRed = pink; // Live Pink (#FF1493)
  static const Color live = pink;
  static const Color error = Color(0xFFFF3366);
  static const Color danger = Color(0xFFE11D48);
  static const Color transparent = Color(0x00000000);

  // =====================================================================
  // Gradients — HEMI TON Brand (Pink · Purple · Blue · Neon Pink · Gold)
  // =====================================================================

  /// Vibrant Pink-to-Purple brand gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [pink, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Electric Pink-to-Blue accent gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [pink, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Neon Pink & Purple Glow gradient
  static const LinearGradient neonGradient = LinearGradient(
    colors: [pink, neonPink, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Golden Yellow gradient for coins & rewards (#FFD700)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE066), gold, Color(0xFFE6AC00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Multistep brand gradient (Pink -> Purple -> Blue -> Purple -> Pink)
  static const LinearGradient metallicGoldGradient = LinearGradient(
    colors: [
      purple,
      pink,
      neonPink,
      pink,
      purple,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Premium diagonal gradient
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [
      purple,
      pink,
      neonPink,
      blue,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark banner gradient on Black
  static const LinearGradient bannerGradient = LinearGradient(
    colors: [
      Color(0xFF000000),
      Color(0xFF0F0B18),
      Color(0xFF160924),
      Color(0xFF000000),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft wash gradient behind screens
  static const LinearGradient bronzeWashGradient = LinearGradient(
    colors: [
      Color(0xFF000000),
      Color(0xFF0D0814),
      Color(0xFF000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // =====================================================================
  // Shadows / Glows
  // =====================================================================
  static List<BoxShadow> goldGlow({
    double alpha = 0.35,
    double blur = 20,
    double spread = 0,
  }) =>
      [
        BoxShadow(
          color: pink.withValues(alpha: alpha),
          blurRadius: blur,
          spreadRadius: spread,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: neonPink.withValues(alpha: alpha * 0.6),
          blurRadius: blur * 0.6,
          offset: const Offset(0, 0),
        ),
      ];

  static List<BoxShadow> neonPinkGlow({
    double alpha = 0.45,
    double blur = 18,
    double spread = 1,
  }) =>
      [
        BoxShadow(
          color: pink.withValues(alpha: alpha),
          blurRadius: blur,
          spreadRadius: spread,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: neonPink.withValues(alpha: alpha * 0.5),
          blurRadius: blur * 0.5,
          offset: const Offset(0, 0),
        ),
      ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];

  // =====================================================================
  // Color Aliases
  // =====================================================================
  static const Color primaryBlue = blue;
  static const Color cyan = blue;
  static const Color violet = purple;
  static const Color accent = pink;
  static const Color primary = pink;
  static const Color deepBlue = darkNavy;
  static const Color lightBlue = Color(0xFFE0F7FA);
  static const Color veryLightSurface = Color(0xFFF8FAFC);
  static const Color lightCardSecondary = Color(0xFFF1F5F9);
  static const Color secondaryTextLight = lightTextSecondary;
  static const Color lightBorderF0 = lightBorder;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color darkTextSecondary = secondaryText;
  static const Color cardBackground = cardBlack;
  static const Color background = black;
  static const Color surface = softBlack;
  static const Color darkBackground = black;
  static const Color darkCard = cardBlack;
  static const Color darkCardSecondary = softBlack;
  static const Color darkSecondarySurface = softBlack;
  static const Color primaryGold = warmGold;
  static const Color secondaryGold = metallicGold;
  static const Color primaryTextDark = primaryText;
  static const Color secondaryTextDark = secondaryText;
  static const Color mutedIconDark = mutedText;
  static const Color borderDark = borderGold;

  static const Color metallicBlue = blue;
  static const Color lightBlueAccent = Color(0xFFE0F7FA);
  static const Color darkNavyAccent = darkNavy;
  static const Color royalBlue = blue;
  static const Color deepRoyalBlue = darkNavy;
  static const Color lightAccent = pink;

  static const LinearGradient metallicBlueGradient = LinearGradient(
    colors: [
      purple,
      blue,
      Color(0xFF80D8FF),
      blue,
      purple,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient premiumBlueGradient = premiumGradient;
  static const LinearGradient bannerBlueGradient = bannerGradient;
  static const LinearGradient vipGradient = premiumGradient;

  // =====================================================================
  // Theme-Aware Helpers
  // DARK MODE:  BACKGROUND IS BLACK (#000000)
  // LIGHT MODE: BACKGROUND IS WHITE (#FFFFFF)
  // =====================================================================
  static Color getPrimary(bool isDark) => pink;
  static Color getPrimaryDeep(bool isDark) => purple;
  static Color getPrimaryLight(bool isDark) => neonPink;
  static Color getOnPrimary(bool isDark) => white;
  static Color getBackground(bool isDark) => isDark ? black : lightBackground;
  static Color getCard(bool isDark) => isDark ? cardBlack : lightCard;
  static Color getSurface(bool isDark) => isDark ? softBlack : lightSurface;
  static Color getTextPrimary(bool isDark) => isDark ? primaryText : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? secondaryText : lightTextSecondary;
  static Color getMuted(bool isDark) => isDark ? mutedText : lightMuted;
  static Color getBorder(bool isDark) => isDark ? borderDarkNavy : lightBorder;
  static Color getBorderStrong(bool isDark) => pink;
  static LinearGradient getAccentGradient(bool isDark) => primaryGradient;
  static LinearGradient getPremiumGradient(bool isDark) => premiumGradient;
  static LinearGradient getBannerGradient(bool isDark) => bannerGradient;

  static Color onPrimary({bool isDark = true}) => white;
  static Color onGold({bool isDark = true}) => white;

  static Color shimmerHighlight({bool isDark = true}) =>
      isDark ? const Color(0xFF202020) : const Color(0xFFE2E8F0);
  static Color shimmerBase({bool isDark = true}) =>
      isDark ? const Color(0xFF101010) : const Color(0xFFF1F5F9);

  static List<BoxShadow> primaryGlow(
    bool isDark, {
    double alpha = 0.35,
    double blur = 20,
    double spread = 0,
  }) =>
      [
        BoxShadow(
          color: pink.withValues(alpha: alpha),
          blurRadius: blur,
          spreadRadius: spread,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: neonPink.withValues(alpha: alpha * 0.5),
          blurRadius: blur * 0.6,
          offset: const Offset(0, 0),
        ),
      ];
}

/// Reusable background widget:
/// Dark Mode  -> PURE BLACK (#000000)
/// Light Mode -> PURE WHITE (#FFFFFF)
class LuxBackground extends StatelessWidget {
  final Widget child;
  final bool showGlow;
  final Alignment glowAlignment;

  const LuxBackground({
    super.key,
    required this.child,
    this.showGlow = true,
    this.glowAlignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.black : AppColors.lightBackground,
      child: Stack(
        children: [
          if (showGlow)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? AppColors.pink : AppColors.purple)
                            .withValues(alpha: isDark ? 0.08 : 0.04),
                        AppColors.transparent,
                        AppColors.transparent,
                      ],
                      radius: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
