import 'package:flutter/material.dart';

class HomeTabIcon extends StatelessWidget {
  final bool isActive;
  final double size;

  const HomeTabIcon({super.key, this.isActive = false, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HomeIconPainter(isActive: isActive, scale: size / 24),
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  final bool isActive;
  final double scale;

  _HomeIconPainter({required this.isActive, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final s = scale;

    final path = Path()
      ..moveTo(12 * s, 3 * s)
      ..lineTo(3 * s, 10 * s)
      ..lineTo(3 * s, 20 * s)
      ..cubicTo(3 * s, 20.55 * s, 3.45 * s, 21 * s, 4 * s, 21 * s)
      ..lineTo(10 * s, 21 * s)
      ..lineTo(10 * s, 15 * s)
      ..lineTo(14 * s, 15 * s)
      ..lineTo(14 * s, 21 * s)
      ..lineTo(20 * s, 21 * s)
      ..cubicTo(20.55 * s, 21 * s, 21 * s, 20.55 * s, 21 * s, 20 * s)
      ..lineTo(21 * s, 10 * s)
      ..close();

    if (isActive) {
      canvas.drawPath(path, Paint()..color = const Color(0xFF1E40AF));
      canvas.drawRect(
        Rect.fromLTWH(10 * s, 15 * s, 4 * s, 6 * s),
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFF9CA3AF),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HomeIconPainter old) => isActive != old.isActive;
}
