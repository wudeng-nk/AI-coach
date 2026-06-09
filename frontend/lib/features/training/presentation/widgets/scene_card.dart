import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/shared/widgets/status_badge.dart';

/// 场景卡数据模型
class SceneCardData {
  final String sceneId;
  final String name;
  final String description;
  final int difficulty; // 1-5
  final String emoji;
  final SceneStatus status;
  final int? completedCount;

  const SceneCardData({
    required this.sceneId,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.emoji,
    required this.status,
    this.completedCount,
  });
}

/// 难度文字标签
String difficultyLabel(int level) {
  if (level <= 2) return '初级';
  if (level <= 3) return '中级';
  return '高级';
}

/// 难度对应颜色
(Color, Color) difficultyColors(int level) {
  if (level <= 2) return (const Color(0xFFC8E6C9), const Color(0xFF2E7D32)); // light green, dark green
  if (level <= 3) return (const Color(0xFFFFE0B2), const Color(0xFFE65100)); // light orange, dark orange
  return (const Color(0xFFFFCDD2), const Color(0xFFC62828)); // light red, dark red
}

/// SceneCard - 匹配设计图的方形卡片
class SceneCard extends StatelessWidget {
  final SceneCardData data;
  final VoidCallback? onSelect;

  const SceneCard({super.key, required this.data, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isLocked = data.status == SceneStatus.locked;

    return GestureDetector(
      onTap: isLocked ? null : onSelect,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 4,
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 主内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // emoji
                  Text(data.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 10),
                  // 场景名称
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 描述
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // 难度标签 - 底部左对齐
                  Builder(builder: (context) {
                    final (bgColor, textColor) = difficultyColors(data.difficulty);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        difficultyLabel(data.difficulty),
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // 状态标签 - 右上角
            Positioned(
              top: 12,
              right: 12,
              child: _StatusChip(status: data.status),
            ),
            // 锁定遮罩
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.lock_outline, size: 32, color: AppColors.textHint),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 状态标签 - 彩色背景 + 白字
class _StatusChip extends StatelessWidget {
  final SceneStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _configs[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.$1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: config.$3,
        ),
      ),
    );
  }

  static final _configs = <SceneStatus, (String, Color, Color)>{
    SceneStatus.completed: ('已完成', const Color(0xFF2196F3), Colors.white),   // 蓝色背景 + 白字
    SceneStatus.inProgress: ('已解锁', const Color(0xFF4CAF50), Colors.white),  // 绿色背景 + 白字
    SceneStatus.locked: ('未解锁', const Color(0xFF9E9E9E), Colors.white),      // 灰色背景 + 白字
  };
}
