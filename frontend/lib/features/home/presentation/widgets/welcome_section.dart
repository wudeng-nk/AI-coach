import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/shared/widgets/gradient_avatar.dart';

class WelcomeSection extends StatelessWidget {
  final String userName;
  final int consecutiveDays;
  final int todayCompleted;

  const WelcomeSection({
    super.key,
    required this.userName,
    this.consecutiveDays = 0,
    this.todayCompleted = 0,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '早上好';
    if (hour >= 12 && hour < 18) return '下午好';
    if (hour >= 18 && hour < 22) return '晚上好';
    return '夜深了';
  }

  String get _message {
    if (consecutiveDays >= 7) return '已连续打卡 $consecutiveDays 天，坚持得很棒！';
    if (todayCompleted == 0) return '今天继续挑战销售场景吧！';
    return '今天已完成 $todayCompleted 次训练，继续加油！';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.welcomeGradientStart, AppColors.welcomeGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GradientAvatar.squirrel(size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👋 $_greeting, $userName',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  _message,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
