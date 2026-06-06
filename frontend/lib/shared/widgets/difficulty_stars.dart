import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';

/// 难度星级组件
class DifficultyStars extends StatelessWidget {
  final int level; // 1-5
  final double size;

  const DifficultyStars({super.key, required this.level, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < level;
        return Icon(
          Icons.star,
          size: size,
          color: filled ? const Color(0xFFFFD700) : const Color(0xFFD9D9D9),
        );
      }),
    );
  }
}

/// 难度文本标签
class DifficultyBadge extends StatelessWidget {
  final int level;

  const DifficultyBadge({super.key, required this.level});

  Color get _color => switch (level) {
    1 || 2 => AppColors.difficultyEasy,
    3 || 4 => AppColors.difficultyMedium,
    _ => AppColors.difficultyHard,
  };

  String get _label => switch (level) {
    1 => '简单',
    2 => '较易',
    3 => '中等',
    4 => '较难',
    _ => '困难',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}
