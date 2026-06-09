import 'package:flutter/material.dart';

import 'package:ai_coach/features/home/data/models/home_models.dart';

class SceneProgressCard extends StatelessWidget {
  final List<SceneProgress> scenes;

  const SceneProgressCard({super.key, required this.scenes});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '场景完成度',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 14),
          ...scenes.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProgressRow(name: s.name, percentage: s.percentage),
          )),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String name;
  final double percentage;

  const _ProgressRow({required this.name, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: const Color(0xFFE8EAF6),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E40AF)),
          ),
        ),
      ],
    );
  }
}
