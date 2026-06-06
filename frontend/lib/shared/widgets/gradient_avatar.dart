import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';

/// 渐变圆形头像 - 用于 IP 角色头像
class GradientAvatar extends StatelessWidget {
  final String emoji;
  final double size;
  final List<Color> gradientColors;
  final double emojiSize;
  final BoxShadow? shadow;

  const GradientAvatar({
    super.key,
    required this.emoji,
    this.size = 80,
    this.gradientColors = const [AppColors.squirrelGradientStart, AppColors.squirrelGradientEnd],
    this.emojiSize = 40,
    this.shadow,
  });

  /// 松鼠刘总
  factory GradientAvatar.squirrel({double size = 80}) {
    return GradientAvatar(
      emoji: '🐿️',
      size: size,
      emojiSize: size * 0.5,
      gradientColors: const [AppColors.squirrelGradientStart, AppColors.squirrelGradientEnd],
      shadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    );
  }

  /// 焦虑型家长 - 橙色猫咪
  factory GradientAvatar.parentAnxious({double size = 64}) {
    return GradientAvatar(
      emoji: '😿',
      size: size,
      emojiSize: size * 0.5,
      gradientColors: [Colors.orange.shade200, Colors.orange.shade400],
    );
  }

  /// 迷茫型家长 - 蓝色猫咪
  factory GradientAvatar.parentConfused({double size = 64}) {
    return GradientAvatar(
      emoji: '🙀',
      size: size,
      emojiSize: size * 0.5,
      gradientColors: [Colors.blue.shade200, Colors.blue.shade400],
    );
  }

  /// 理性型家长 - 绿色猫咪
  factory GradientAvatar.parentRational({double size = 64}) {
    return GradientAvatar(
      emoji: '😼',
      size: size,
      emojiSize: size * 0.5,
      gradientColors: [Colors.green.shade200, Colors.green.shade400],
    );
  }

  /// 观望型家长 - 灰色猫咪
  factory GradientAvatar.parentWatcher({double size = 64}) {
    return GradientAvatar(
      emoji: '😺',
      size: size,
      emojiSize: size * 0.5,
      gradientColors: [Colors.grey.shade300, Colors.grey.shade400],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: shadow != null ? [shadow!] : null,
        border: Border.all(color: Colors.white, width: size > 50 ? 3 : 2),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
      ),
    );
  }
}
