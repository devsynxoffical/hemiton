import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable application logo widget for HEMI TON.
/// Features a modern, gradient-accented "H" emblem with neon glow.
/// When the user provides the official logo image (hemiton_logo.png),
/// it will load seamlessly; otherwise it displays this premium brand emblem.
class AppLogo extends StatelessWidget {
  final double size;
  final double? borderRadius;
  final bool showGlow;
  final bool showBorder;
  final BoxBorder? customBorder;
  final VoidCallback? onTap;

  const AppLogo({
    super.key,
    this.size = 40,
    this.borderRadius,
    this.showGlow = false,
    this.showBorder = false,
    this.customBorder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? (size * 0.24);

    Widget emblem = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.pink,
            AppColors.purple,
            AppColors.blue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: size > 60 ? 2.0 : 1.2,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.55),
                  blurRadius: size * 0.35,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.neonPink.withValues(alpha: 0.35),
                  blurRadius: size * 0.2,
                  offset: const Offset(0, 0),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          'H',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.52,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );

    // If an official asset image exists, try loading it with error fallback to the emblem
    Widget logoWidget = ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: Image.asset(
        'assets/images/hemiton_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => emblem,
      ),
    );

    if (showBorder || customBorder != null) {
      logoWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(effectiveRadius),
          border: customBorder ??
              Border.all(
                color: AppColors.pink.withValues(alpha: 0.5),
                width: size > 60 ? 2.0 : 1.2,
              ),
        ),
        child: logoWidget,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: logoWidget,
      );
    }

    return logoWidget;
  }
}
