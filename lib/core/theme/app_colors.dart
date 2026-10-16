import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Design System — HEMI TON
///
/// Palette:
/// - Pink:            #FF1493 (Primary Accent / CTA / Selected Tab)
/// - Purple:          #8A2BE2 (Secondary Accent / Gradients)
/// - Blue:            #00BFFF (Electric Sky Blue / Badges)
/// - Dark Navy:       #00152E (Deep Background & Dark Mode Surface)
/// - White:           #FFFFFF (Light Mode Background & Crisp Contrast)
/// - Golden Yellow:   #FFD700 (Coins, VIP, Special Rewards)
/// - Neon Pink Glow:  #FF00FF (Highlights, Glows, Live Pulse)
/// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  // =====================================================================
  // HEMI TON Official Brand Palette
  // =====================================================================
  static const Color pink = Color(0xFFFF1493);
  static const Color purple = Color(0xFF8A2BE2);
  static const Color blue = Color(0xFF00BFFF);
  static const Color darkNavy = Color(0xFF00152E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldenYellow = Color(0xFFFFD700);
  static const Color neonPink = Color(0xFFFF00FF);

  // Surfaces / Tints derived from Dark Navy
  static const Color cardNavy = Color(0xFF072142);
  static const Color softNavy = Color(0xFF0D2D56);
  static const Color borderNavy = Color(0xFF143868);
  static const Color lightNavy = Color(0xFF133663);

  // =====================================================================
  // Dark Surfaces (Mapped to Dark Navy System)
  // =====================================================================
  static const Color black = Color(0xFF00152E); // Dark Navy background
  static const Color darkBlack = Color(0xFF001024); // Deeper Dark Navy
  static const Color cardBlack = Color(0xFF072142); // Card Navy
  static const Color softBlack = Color(0xFF0D2D56); // Soft Navy Surface

  // Light-mode surfaces (White theme)
  static const Color champagne = Color(0xFFF4F7FB);
  static const Color champagneCard = Color(0xFFFFFFFF);
  static const Color champagneSoft = Color(0xFFE8EEF5);

  // =====================================================================
  // Primary Accents (Pink / Purple / Blue / Neon Pink)
  // =====================================================================
  static const Color warmGold = pink; // Primary Pink (#FF1493)
  static const Color metallicGold = purple; // Purple (#8A2BE2)
  static const Color lightGold = neonPink; // Neon Pink (#FF00FF)
  static const Color deepBronze = blue; // Electric Blue (#00BFFF)
  static const Color goldBorder = pink; // Pink border
  static const Color goldHighlight = neonPink; // Neon glow
  static const Color borderGold = borderNavy; // Dark navy border

  // =====================================================================
  // Text
  // =====================================================================
  static const Color primaryText = Color(0xFFFFFFFF); // White
  static const Color secondaryText = Color(0xFFB0C4DE); // Light Steel Navy
  static const Color mutedText = Color(0xFF7A94B8); // Muted Navy

  // =====================================================================
  // Status / System
  // =====================================================================
  static const Color success = Color(0xFF10B981);
  static const Color liveGreen = Color(0xFF10B981);
  static const Color liveRed = pink; // Live Pink
  static const Color live = pink;
  static const Color error = Color(0xFFFF3366);
  static const Color danger = Color(0xFFE11D48);
  static const Color transparent = Color(0x00000000);

  // =====================================================================
  // Gradients — HEMI TON
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

  /// Golden Yellow gradient for coins and special rewards
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE066), gold, Color(0xFFE6AC00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Multistep metallic gradient
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

  /// Dark Navy reflection banner gradient
  static const LinearGradient bannerGradient = LinearGradient(
    colors: [
      Color(0xFF00152E),
      Color(0xFF0A2244),
      Color(0xFF1A123C),
      Color(0xFF00152E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Navy wash gradient behind screens
  static const LinearGradient bronzeWashGradient = LinearGradient(
    colors: [
      Color(0xFF00152E),
      Color(0xFF072142),
      Color(0xFF00152E),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Soft pink radial glow
  static final RadialGradient radialGoldGlow = RadialGradient(
    colors: [
      pink.withValues(alpha: 0.20),
      purple.withValues(alpha: 0.08),
      transparent,
    ],
    radius: 1.1,
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
  // Light Mode Palette — White · Pink · Purple · Dark Navy
  // =====================================================================
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF3F6FA);
  static const Color lightTextPrimary = Color(0xFF00152E); // Dark Navy text
  static const Color lightTextSecondary = Color(0xFF334E68);
  static const Color lightMuted = Color(0xFF627D98);
  static const Color lightBorder = Color(0xFFDCE4EC);
  static const Color lightAccent = pink;

  static const Color metallicBlue = blue;
  static const Color lightBlueAccent = Color(0xFFE1F5FE);
  static const Color darkNavyAccent = darkNavy;
  static const Color royalBlue = blue;
  static const Color deepRoyalBlue = Color(0xFF0288D1);

  // =====================================================================
  // Primary & Color Aliases
  // =====================================================================
  static const Color primaryBlue = blue;
  static const Color cyan = blue;
  static const Color violet = purple;
  static const Color accent = pink;
  static const Color primary = pink;
  static const Color deepBlue = Color(0xFF00224D);
  static const Color lightBlue = Color(0xFFE1F5FE);
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

  // Dark-mode aliases
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

  // Blue / Secondary gradients
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

  static const LinearGradient premiumBlueGradient = LinearGradient(
    colors: [
      purple,
      blue,
      neonPink,
      pink,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerBlueGradient = bannerGradient;
  static const LinearGradient vipGradient = premiumGradient;

  // =====================================================================
  // Theme-aware helpers
  // Dark Mode  = Dark Navy (#00152E) + Pink (#FF1493) + Purple (#8A2BE2)
  // Light Mode = White (#FFFFFF) + Pink (#FF1493) + Dark Navy (#00152E)
  // =====================================================================
  static Color getPrimary(bool isDark) => pink;
  static Color getPrimaryDeep(bool isDark) => purple;
  static Color getPrimaryLight(bool isDark) => neonPink;
  static Color getOnPrimary(bool isDark) => white;
  static Color getBackground(bool isDark) => isDark ? darkNavy : lightBackground;
  static Color getCard(bool isDark) => isDark ? cardNavy : lightCard;
  static Color getSurface(bool isDark) => isDark ? softNavy : lightSurface;
  static Color getTextPrimary(bool isDark) => isDark ? white : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? secondaryText : lightTextSecondary;
  static Color getMuted(bool isDark) => isDark ? mutedText : lightMuted;
  static Color getBorder(bool isDark) => isDark ? borderNavy : lightBorder;
  static Color getBorderStrong(bool isDark) => pink;
  static LinearGradient getAccentGradient(bool isDark) => primaryGradient;
  static LinearGradient getPremiumGradient(bool isDark) => premiumGradient;
  static LinearGradient getBannerGradient(bool isDark) => bannerGradient;

  static Color onPrimary({bool isDark = true}) => white;
  static Color onGold({bool isDark = true}) => white;

  static Color shimmerHighlight({bool isDark = true}) =>
      isDark ? const Color(0xFF143868) : const Color(0xFFE2E8F0);
  static Color shimmerBase({bool isDark = true}) =>
      isDark ? const Color(0xFF072142) : const Color(0xFFF1F5F9);

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

/// Reusable background that layers a soft radial glow over the canvas.
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
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00152E), // Dark Navy
                  Color(0xFF001024),
                  Color(0xFF00152E),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF7FAFD),
                  Color(0xFFF0F5FA),
                ],
              ),
      ),
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
                            .withValues(alpha: isDark ? 0.12 : 0.05),
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
