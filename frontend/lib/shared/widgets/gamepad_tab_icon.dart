import 'package:flutter/material.dart';

class GamepadTabIcon extends StatelessWidget {
  final bool isActive;
  final double size;

  const GamepadTabIcon({super.key, this.isActive = false, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GamepadIconPainter(isActive: isActive, scale: size / 24),
    );
  }
}

class _GamepadIconPainter extends CustomPainter {
  final bool isActive;
  final double scale;

  _GamepadIconPainter({required this.isActive, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final s = scale;
    final color = isActive ? const Color(0xFF1E40AF) : const Color(0xFF9CA3AF);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isActive ? 1.8 : 1.5) * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    if (isActive) {
      paint.style = PaintingStyle.fill;
    }

    // 手柄主体 - 圆角矩形
    final bodyRrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2 * s, 7 * s, 20 * s, 12 * s),
      Radius.circular(4 * s),
    );

    if (isActive) {
      canvas.drawRRect(bodyRrect, Paint()..color = color);
      paint.color = Colors.white;
      paint.style = PaintingStyle.stroke;
    } else {
      canvas.drawRRect(bodyRrect, paint);
    }

    // 左侧十字方向键
    final crossPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (isActive ? 2.0 : 1.5) * s
      ..strokeCap = StrokeCap.round
      ..color = isActive ? Colors.white : color;

    // 竖线
    canvas.drawLine(
      Offset(7 * s, 10 * s),
      Offset(7 * s, 16 * s),
      crossPaint,
    );
    // 横线
    canvas.drawLine(
      Offset(4 * s, 13 * s),
      Offset(10 * s, 13 * s),
      crossPaint,
    );

    // 右侧按钮 - 两个小圆
    final buttonPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isActive ? Colors.white : color;

    canvas.drawCircle(Offset(16 * s, 11.5 * s), 1.2 * s, buttonPaint);
    canvas.drawCircle(Offset(19 * s, 14 * s), 1.2 * s, buttonPaint);
  }

  @override
  bool shouldRepaint(covariant _GamepadIconPainter old) => isActive != old.isActive;
}
