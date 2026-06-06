import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/features/home/data/models/home_models.dart';

class HotScenesCard extends StatelessWidget {
  final List<HotScene> scenes;
  final ValueChanged<String> onSceneTap;

  const HotScenesCard({super.key, required this.scenes, required this.onSceneTap});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text(
                '热门场景',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: scenes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final scene = scenes[index];
                return _SceneTag(
                  emoji: scene.emoji,
                  name: scene.sceneName,
                  onTap: () => onSceneTap(scene.sceneId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneTag extends StatelessWidget {
  final String emoji;
  final String name;
  final VoidCallback onTap;

  const _SceneTag({required this.emoji, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
