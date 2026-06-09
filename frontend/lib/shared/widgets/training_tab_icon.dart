import 'package:flutter/material.dart';

class TrainingTabIcon extends StatelessWidget {
  final bool isActive;
  final double size;

  const TrainingTabIcon({super.key, this.isActive = false, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrainingIconPainter(isActive: isActive, scale: size / 24),
    );
  }
}

class _TrainingIconPainter extends CustomPainter {
  final bool isActive;
  final double scale;

  _TrainingIconPainter({required this.isActive, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final s = scale;
    final color = isActive ? const Color(0xFF1E40AF) : const Color(0xFF9CA3AF);
    final strokeWidth = isActive ? 2.0 * s : 1.5 * s;

    // 麦克风主体 (rounded rect: x=9, y=4, w=6, h=10, rx=3)
    final bodyRrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(9 * s, 4 * s, 6 * s, 10 * s),
      Radius.circular(3 * s),
    );

    if (isActive) {
      canvas.drawRRect(bodyRrect, Paint()..color = color);
    } else {
      canvas.drawRRect(
        bodyRrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = color,
      );
    }

    // 麦克风底座弧线
    final arcPath = Path();
    arcPath.moveTo(7 * s, 14 * s);
    arcPath.cubicTo(7 * s, 16.76 * s, 9.24 * s, 19 * s, 12 * s, 19 * s);
    arcPath.cubicTo(14.76 * s, 19 * s, 17 * s, 16.76 * s, 17 * s, 14 * s);
    canvas.drawPath(
      arcPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    // 支架竖线
    canvas.drawLine(
      Offset(12 * s, 19 * s),
      Offset(12 * s, 22 * s),
      Paint()
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    // 支架横线
    canvas.drawLine(
      Offset(9 * s, 22 * s),
      Offset(15 * s, 22 * s),
      Paint()
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    // 音波装饰
    if (isActive) {
      canvas.drawCircle(
        Offset(12 * s, 9 * s),
        2 * s,
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
      canvas.drawCircle(
        Offset(12 * s, 9 * s),
        1 * s,
        Paint()..color = Colors.white,
      );
    } else {
      canvas.drawCircle(
        Offset(12 * s, 9 * s),
        1.5 * s,
        Paint()..color = color.withValues(alpha: 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrainingIconPainter old) => isActive != old.isActive;
}
