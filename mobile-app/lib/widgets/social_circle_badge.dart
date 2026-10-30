import 'package:flutter/material.dart';
import 'social_circle_sheet.dart';

class SocialCircleBadge extends StatelessWidget {
  final String circleName;
  final String? circleId;
  final String iconEmoji;
  final VoidCallback? onTap;
  final bool isInteractive;

  const SocialCircleBadge({
    super.key,
    required this.circleName,
    this.circleId,
    this.iconEmoji = '💜',
    this.onTap,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (circleName.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: isInteractive
          ? () {
              if (onTap != null) {
                onTap!();
              } else {
                SocialCircleSheet.show(context);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8A2387), Color(0xFFE94057)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE94057).withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            Text(
              circleName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
