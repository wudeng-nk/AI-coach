import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';

/// 状态标签组件 - 已通关/挑战中/未解锁
enum SceneStatus { completed, inProgress, locked }

class StatusBadge extends StatelessWidget {
  final SceneStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(config.$3, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            config.$1,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: config.$4),
          ),
        ],
      ),
    );
  }

  static final _statusConfig = <SceneStatus, (String, Color, String, Color)>{
    SceneStatus.completed: ('已通关', AppColors.statusCompletedBg, '✅', AppColors.statusCompleted),
    SceneStatus.inProgress: ('挑战中', AppColors.statusInProgressBg, '🔥', AppColors.statusInProgress),
    SceneStatus.locked: ('未解锁', AppColors.statusLockedBg, '🔒', AppColors.statusLocked),
  };
}
