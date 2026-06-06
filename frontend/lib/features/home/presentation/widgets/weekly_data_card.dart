import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/features/home/data/models/home_models.dart';

class WeeklyDataCard extends StatelessWidget {
  final WeeklyData data;
  final VoidCallback? onTap;

  const WeeklyDataCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text(
                '本周数据',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onTap,
                child: const Text(
                  '查看更多',
                  style: TextStyle(fontSize: 14, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DataItem(
                value: '${data.completedCount}',
                label: '已完成',
                trend: data.completedTrend,
              ),
              _DataItem(
                value: '${data.averageScore}',
                label: '平均分',
                trend: data.scoreTrend,
              ),
              _DataItem(
                value: '${data.passRate}%',
                label: '通关率',
                trend: data.passRateTrend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataItem extends StatelessWidget {
  final String value;
  final String label;
  final int trend;

  const _DataItem({required this.value, required this.label, required this.trend});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
        if (trend != 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                trend > 0 ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: trend > 0 ? AppColors.success : AppColors.error,
              ),
              Text(
                '${trend > 0 ? '+' : ''}$trend',
                style: TextStyle(
                  fontSize: 12,
                  color: trend > 0 ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
