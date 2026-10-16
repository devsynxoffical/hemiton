import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ---------------------------------------------------------------------------
/// AppThemeColors — a single resolved palette for HEMI TON.
///
/// USAGE in any widget:
///   final tc = AppThemeColors.of(context);
///   container.color = tc.primary;     // Pink (#FF1493)
///   text.color     = tc.textPrimary;  // White (dark) or Dark Navy (light)
///
/// Dark mode  → Dark Navy (#00152E) + Pink (#FF1493) + Purple (#8A2BE2)
/// Light mode → White (#FFFFFF) + Pink (#FF1493) + Dark Navy (#00152E)
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
  Color get background      => isDark ? AppColors.darkNavy       : AppColors.lightBackground;
  Color get card            => isDark ? AppColors.cardNavy       : AppColors.lightCard;
  Color get surface         => isDark ? AppColors.softNavy       : AppColors.lightSurface;
  Color get surfaceVariant  => isDark ? AppColors.darkBlack      : AppColors.lightCardSecondary;

  // ── Primary accent (Pink & Purple) ────────────────────────────────────────
  Color get primary         => AppColors.pink;
  Color get primaryDeep     => AppColors.purple;
  Color get primaryLight    => AppColors.neonPink;
  Color get primaryBorder   => AppColors.pink;
  Color get primaryMuted    => isDark ? AppColors.purple.withValues(alpha: 0.5) : AppColors.purple.withValues(alpha: 0.25);
  Color get onPrimary       => AppColors.white;

  // ── Text ─────────────────────────────────────────────────────────────────
  Color get textPrimary     => isDark ? AppColors.white          : AppColors.darkNavy;
  Color get textSecondary   => isDark ? AppColors.secondaryText  : AppColors.lightTextSecondary;
  Color get textMuted       => isDark ? AppColors.mutedText      : AppColors.lightMuted;

  // ── Borders ───────────────────────────────────────────────────────────────
  Color get border          => isDark ? AppColors.borderNavy     : AppColors.lightBorder;
  Color get borderStrong    => isDark ? AppColors.pink           : AppColors.pink.withValues(alpha: 0.7);

  // ── Gradients ─────────────────────────────────────────────────────────────
  LinearGradient get accentGradient   => AppColors.primaryGradient;
  LinearGradient get premiumGradient  => AppColors.premiumGradient;
  LinearGradient get bannerGradient   => AppColors.bannerGradient;
  LinearGradient get backgroundGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF00152E), Color(0xFF001024), Color(0xFF00152E)],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFD), Color(0xFFF0F5FA)],
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
