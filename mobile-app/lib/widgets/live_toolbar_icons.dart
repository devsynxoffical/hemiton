import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 1. White Speech Bubble Icon with two dark horizontal lines inside + Green/Red unread dot
/// Matches icon #3 in the reference toolbar image.
class NextChatBubbleIcon extends StatelessWidget {
  final bool hasUnread;
  final double size;

  const NextChatBubbleIcon({
    super.key,
    required this.hasUnread,
    this.size = 27,
  });

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(s, s),
            painter: _SpeechBubblePainter(),
          ),
          Positioned(
            top: -1.w,
            right: -1.w,
            child: Container(
              width: 8.5.w,
              height: 8.5.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasUnread ? const Color(0xFF00E676) : const Color(0xFFFF1744),
                border: Border.all(color: const Color(0xFF0D0F18), width: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw circular speech bubble body
    final center = Offset(w * 0.5, h * 0.48);
    final radius = w * 0.44;
    canvas.drawCircle(center, radius, paint);

    // Draw bottom-right tail matching reference image
    final tailPath = Path()
      ..moveTo(w * 0.65, h * 0.82)
      ..lineTo(w * 0.88, h * 0.92)
      ..lineTo(w * 0.82, h * 0.66)
      ..close();
    canvas.drawPath(tailPath, paint);

    // Draw two horizontal dark lines inside the bubble
    final linePaint = Paint()
      ..color = const Color(0xFF141722)
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Top line (longer)
    canvas.drawLine(
      Offset(w * 0.31, h * 0.41),
      Offset(w * 0.69, h * 0.41),
      linePaint,
    );

    // Bottom line (shorter)
    canvas.drawLine(
      Offset(w * 0.31, h * 0.56),
      Offset(w * 0.55, h * 0.56),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. White Gamepad with Golden Crown on top (No background circle)
/// Matches icon #4 in the reference toolbar image.
class GamesCrownIcon extends StatelessWidget {
  final double size;

  const GamesCrownIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            child: CustomPaint(
              size: Size(s * 0.48, s * 0.32),
              painter: _GoldCrownPainter(),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Icon(
              Icons.sports_esports_rounded,
              color: Colors.white,
              size: s * 0.82,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldCrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE066), Color(0xFFFFB300)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(w * 0.1, h)
      ..lineTo(0, h * 0.25)
      ..lineTo(w * 0.3, h * 0.6)
      ..lineTo(w * 0.5, 0)
      ..lineTo(w * 0.7, h * 0.6)
      ..lineTo(w, h * 0.25)
      ..lineTo(w * 0.9, h)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. Golden Laurel Wreath Ring Icon (No background circle)
/// Matches icon #5 in the reference toolbar image.
class GoldenLaurelWreathIcon extends StatelessWidget {
  final double size;

  const GoldenLaurelWreathIcon({super.key, this.size = 27});

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    return SizedBox(
      width: s,
      height: s,
      child: CustomPaint(
        size: Size(s, s),
        painter: _LaurelWreathPainter(),
      ),
    );
  }
}

class _LaurelWreathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.36;

    final goldGradient = const LinearGradient(
      colors: [Color(0xFFFFE066), Color(0xFFFFB300), Color(0xFFFF8F00)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final branchPaint = Paint()
      ..shader = goldGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final leafPaint = Paint()
      ..shader = goldGradient
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Left arc branch
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.58,
      math.pi * 0.75,
      false,
      branchPaint,
    );

    // Right arc branch
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.33,
      math.pi * 0.75,
      false,
      branchPaint,
    );

    // Draw laurel leaves along left and right arcs
    const int leafCount = 5;
    for (int i = 0; i < leafCount; i++) {
      final t = i / (leafCount - 1);
      // Left side angle from bottom-left to top-left
      final leftAngle = math.pi * (0.65 + t * 0.62);
      _drawLeaf(canvas, center, radius, leftAngle, w * 0.14, w * 0.07, true, leafPaint);

      // Right side angle from bottom-right to top-right
      final rightAngle = math.pi * (0.35 - t * 0.62);
      _drawLeaf(canvas, center, radius, rightAngle, w * 0.14, w * 0.07, false, leafPaint);
    }

    // Bottom ribbon tie
    final tiePaint = Paint()
      ..shader = goldGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.42, h * 0.86),
      Offset(w * 0.58, h * 0.86),
      tiePaint,
    );
  }

  void _drawLeaf(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    double leafLen,
    double leafWidth,
    bool isLeft,
    Paint paint,
  ) {
    final pos = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle + (isLeft ? -math.pi * 0.35 : math.pi * 0.35));
    final rect = Rect.fromCenter(center: Offset.zero, width: leafLen, height: leafWidth);
    canvas.drawOval(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4. Hot Pink Gift Box with Golden Ribbon & Bow (No background circle)
/// Matches icon #6 in the reference toolbar image.
class PinkGiftBoxIcon extends StatelessWidget {
  final double size;

  const PinkGiftBoxIcon({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    return SizedBox(
      width: s,
      height: s,
      child: CustomPaint(
        size: Size(s, s),
        painter: _PinkGiftBoxPainter(),
      ),
    );
  }
}

class _PinkGiftBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Golden Bow on top
    final goldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE066), Color(0xFFFFB300)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Left bow loop
    final leftBow = Path()
      ..moveTo(w * 0.5, h * 0.26)
      ..cubicTo(w * 0.22, h * 0.02, w * 0.15, h * 0.28, w * 0.5, h * 0.26);
    canvas.drawPath(leftBow, goldPaint);

    // Right bow loop
    final rightBow = Path()
      ..moveTo(w * 0.5, h * 0.26)
      ..cubicTo(w * 0.78, h * 0.02, w * 0.85, h * 0.28, w * 0.5, h * 0.26);
    canvas.drawPath(rightBow, goldPaint);

    // 2. Lower Box Body (Hot Pink)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF2A85), Color(0xFFE0115F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.38, w, h * 0.56))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.40, w * 0.72, h * 0.52),
      Radius.circular(w * 0.09),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // 3. Lid (Bright Pink)
    final lidPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF4D94), Color(0xFFFF1476)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.24, w, h * 0.18))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final lidRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.09, h * 0.25, w * 0.82, h * 0.17),
      Radius.circular(w * 0.07),
    );
    canvas.drawRRect(lidRRect, lidPaint);

    // 4. Vertical Gold Ribbon across lid & body
    final ribbonFill = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE066), Color(0xFFFF9800)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.25, w, h * 0.67))
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(w * 0.43, h * 0.25, w * 0.14, h * 0.67),
      ribbonFill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 5. Clean White Paper Airplane Share Icon (No background circle)
/// Matches icon #7 in the reference toolbar image.
class PaperPlaneShareIcon extends StatelessWidget {
  final double size;

  const PaperPlaneShareIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    return SizedBox(
      width: s,
      height: s,
      child: Center(
        child: Transform.rotate(
          angle: -0.45,
          child: Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: s * 0.92,
          ),
        ),
      ),
    );
  }
}
