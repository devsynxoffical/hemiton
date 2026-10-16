import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ---------------------------------------------------------------------------
/// AppThemeColors — a single resolved palette for HEMI TON.
///
/// Dark mode  → PURE BLACK (#000000) Background + Pink (#FF1493) & Purple (#8A2BE2)
/// Light mode → PURE WHITE (#FFFFFF) Background + Pink (#FF1493) & Dark Navy (#00152E)
/// ---------------------------------------------------------------------------
class AppThemeColors {
  final bool isDark;

  const AppThemeColors._(this.isDark);

  /// Resolve from [BuildContext].
  factory AppThemeColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppThemeColors._(isDark);
  }

  // ── Surfaces / Backgrounds ────────────────────────────────────────────────
  Color get background      => isDark ? AppColors.black          : AppColors.lightBackground;
  Color get card            => isDark ? AppColors.cardBlack      : AppColors.lightCard;
  Color get surface         => isDark ? AppColors.softBlack      : AppColors.lightSurface;
  Color get surfaceVariant  => isDark ? AppColors.darkBlack      : AppColors.lightCardSecondary;

  // ── Primary accent (Pink & Purple) ────────────────────────────────────────
  Color get primary         => AppColors.pink;
  Color get primaryDeep     => AppColors.purple;
  Color get primaryLight    => AppColors.neonPink;
  Color get primaryBorder   => AppColors.pink;
  Color get primaryMuted    => isDark ? AppColors.purple.withValues(alpha: 0.5) : AppColors.purple.withValues(alpha: 0.25);
  Color get onPrimary       => AppColors.white;

  // ── Text ─────────────────────────────────────────────────────────────────
  Color get textPrimary     => isDark ? AppColors.primaryText    : AppColors.lightTextPrimary;
  Color get textSecondary   => isDark ? AppColors.secondaryText  : AppColors.lightTextSecondary;
  Color get textMuted       => isDark ? AppColors.mutedText      : AppColors.lightMuted;

  // ── Borders ───────────────────────────────────────────────────────────────
  Color get border          => isDark ? AppColors.borderDarkNavy : AppColors.lightBorder;
  Color get borderStrong    => AppColors.pink;

  // ── Gradients ─────────────────────────────────────────────────────────────
  LinearGradient get accentGradient   => AppColors.primaryGradient;
  LinearGradient get premiumGradient  => AppColors.premiumGradient;
  LinearGradient get bannerGradient   => AppColors.bannerGradient;
  LinearGradient get backgroundGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0xFF080808), Color(0xFF000000)],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFC), Color(0xFFFFFFFF)],
        );

  // ── Shadows / Glows ───────────────────────────────────────────────────────
  List<BoxShadow> primaryGlow({double alpha = 0.35, double blur = 20, double spread = 0}) => [
    BoxShadow(
      color: primary.withValues(alpha: alpha),
      blurRadius: blur,
      spreadRadius: spread,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.neonPink.withValues(alpha: alpha * 0.5),
      blurRadius: blur * 0.6,
      offset: const Offset(0, 0),
    ),
  ];

  // ── Status ────────────────────────────────────────────────────────────────
  Color get live     => AppColors.pink;
  Color get success  => const Color(0xFF10B981);
  Color get error    => const Color(0xFFFF3366);
}
