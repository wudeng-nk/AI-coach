import 'package:flutter/material.dart';

class ChartTabIcon extends StatelessWidget {
  final bool isActive;
  final double size;

  const ChartTabIcon({super.key, this.isActive = false, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ChartIconPainter(isActive: isActive, scale: size / 24),
    );
  }
}

class _ChartIconPainter extends CustomPainter {
  final bool isActive;
  final double scale;

  _ChartIconPainter({required this.isActive, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final s = scale;
    final color = isActive ? const Color(0xFF1E40AF) : const Color(0xFF9CA3AF);

    final paint = Paint()
      ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round
      ..color = color;

    // 第一根柱子（矮）
    final bar1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(3 * s, 13 * s, 4 * s, 8 * s),
      Radius.circular(1 * s),
    );
    canvas.drawRRect(bar1, paint);

    // 第二根柱子（中）
    final bar2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(10 * s, 7 * s, 4 * s, 14 * s),
      Radius.circular(1 * s),
      );
    canvas.drawRRect(bar2, paint);

    // 第三根柱子（高）
    final bar3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(17 * s, 3 * s, 4 * s, 18 * s),
      Radius.circular(1 * s),
    );
    canvas.drawRRect(bar3, paint);

    // 底部基线
    if (!isActive) {
      canvas.drawLine(
        Offset(2 * s, 22 * s),
        Offset(22 * s, 22 * s),
        Paint()
          ..strokeWidth = 1.5 * s
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartIconPainter old) => isActive != old.isActive;
}
