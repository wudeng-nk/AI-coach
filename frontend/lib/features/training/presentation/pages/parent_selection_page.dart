import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/shared/widgets/gradient_avatar.dart';
import 'package:ai_coach/shared/widgets/difficulty_stars.dart';

/// 家长类型数据
class ParentType {
  final String id;
  final String name;
  final String emoji;
  final String typicalQuote;
  final String personality;
  final String coreNeed;
  final int difficulty;
  final GradientAvatar Function({double size}) avatarFactory;
  final Color tagColor;

  const ParentType({
    required this.id,
    required this.name,
    required this.emoji,
    required this.typicalQuote,
    required this.personality,
    required this.coreNeed,
    required this.difficulty,
    required this.avatarFactory,
    required this.tagColor,
  });
}

/// 家长选择页
class ParentSelectionPage extends StatelessWidget {
  final String sceneId;

  const ParentSelectionPage({super.key, required this.sceneId});

  static const _parents = [
    ParentType(
      id: 'P-01',
      name: '焦虑型妈妈',
      emoji: '😿',
      typicalQuote: '"我家孩子数学越来越差了，怎么办？"',
      personality: '紧张、急切、话多、容易动摇',
      coreNeed: '被理解 + 看到希望 + 确认效果',
      difficulty: 3,
      avatarFactory: GradientAvatar.parentAnxious,
      tagColor: AppColors.parentAnxious,
    ),
    ParentType(
      id: 'P-02',
      name: '迷茫型爸爸',
      emoji: '🙀',
      typicalQuote: '"学而思和你们有什么区别？"',
      personality: '犹豫、信息量大但无判断力',
      coreNeed: '帮他建立清晰的判断框架',
      difficulty: 4,
      avatarFactory: GradientAvatar.parentConfused,
      tagColor: AppColors.parentConfused,
    ),
    ParentType(
      id: 'P-03',
      name: '理性型爸爸',
      emoji: '😼',
      typicalQuote: '"你们的数据能证明效果吗？"',
      personality: '务实、数据驱动、不喜欢被推销',
      coreNeed: '硬核证据 + 政策分析 + 性价比论证',
      difficulty: 5,
      avatarFactory: GradientAvatar.parentRational,
      tagColor: AppColors.parentRational,
    ),
    ParentType(
      id: 'P-04',
      name: '观望型家长',
      emoji: '😺',
      typicalQuote: '"随便看看，孩子还小不着急"',
      personality: '好奇、无压力、随时可能走',
      coreNeed: '建立品牌印象，种下种子',
      difficulty: 2,
      avatarFactory: GradientAvatar.parentWatcher,
      tagColor: AppColors.parentWatcher,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('选择家长 — $sceneId'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _parents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = _parents[index];
          return _ParentCard(
            parent: p,
            onTap: () => context.push('/training/chat/${p.id}'),
          );
        },
      ),
    );
  }
}

class _ParentCard extends StatelessWidget {
  final ParentType parent;
  final VoidCallback onTap;

  const _ParentCard({required this.parent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // 头像
            parent.avatarFactory(size: 64),
            const SizedBox(width: 16),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        parent.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: parent.tagColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          parent.emoji,
                          style: TextStyle(fontSize: 12, color: parent.tagColor),
                        ),
                      ),
                      const Spacer(),
                      DifficultyStars(level: parent.difficulty, size: 12),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    parent.personality,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    parent.typicalQuote,
                    style: const TextStyle(fontSize: 13, color: AppColors.textHint, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
