import 'dart:math';
import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy progress ring widget.
/// A circular progress indicator used in admin summary cards.
class SmesProgressRing extends StatelessWidget {
  final double value;       // 0.0 – 1.0
  final double size;
  final Color color;
  final double strokeWidth;
  final Widget? child;

  const SmesProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.color = const Color(0xFF065F46),
    this.strokeWidth = 6,
    this.child,
  });

  /// Convenience constructor that shows a percentage label in the centre.
  factory SmesProgressRing.withPercent(
    double value, {
    double size = 64,
    Color color = const Color(0xFF065F46),
  }) {
    final pct = (value * 100).round();
    return SmesProgressRing(
      value: value,
      size: size,
      color: color,
      child: Text(
        '$pct%',
        style: TextStyle(
          fontSize: size * 0.22,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          color: color,
          strokeWidth: strokeWidth,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final double strokeWidth;

  const _RingPainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(strokeWidth / 2), -pi / 2, 2 * pi, false, trackPaint);
    canvas.drawArc(rect.deflate(strokeWidth / 2), -pi / 2, 2 * pi * value, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.strokeWidth != strokeWidth;
}
