import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/features/home/data/models/home_models.dart';
import 'package:ai_coach/shared/widgets/difficulty_stars.dart';

class RecommendCard extends StatelessWidget {
  final RecommendationData recommendation;
  final VoidCallback onStart;

  const RecommendCard({
    super.key,
    required this.recommendation,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.recommendGradientStart, AppColors.recommendGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                '智能推荐',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const Spacer(),
              DifficultyStars(level: recommendation.difficulty, size: 12),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${recommendation.sceneName} × ${recommendation.parentName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '⏱️ ${recommendation.estimatedDuration}',
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.reason,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7), height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('立即开始', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
