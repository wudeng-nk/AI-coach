import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/shared/widgets/difficulty_stars.dart';
import 'package:ai_coach/shared/widgets/status_badge.dart';

/// 场景卡数据模型
class SceneCardData {
  final String sceneId;
  final String name;
  final String description;
  final int difficulty; // 1-5
  final String duration;
  final String emoji;
  final SceneStatus status;
  final int? completedCount;
  final List<String> keyActions;
  final String successCriteria;
  final String failureSignals;
  final List<String> recommendedSkills;

  const SceneCardData({
    required this.sceneId,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.emoji,
    required this.status,
    this.completedCount,
    required this.keyActions,
    required this.successCriteria,
    required this.failureSignals,
    required this.recommendedSkills,
  });
}

/// SceneCard - 3D 翻转卡片
class SceneCard extends StatefulWidget {
  final SceneCardData data;
  final VoidCallback? onSelect;

  const SceneCard({super.key, required this.data, this.onSelect});

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.data.status == SceneStatus.locked;

    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, _) {
        final angle = _flipController.value * 3.14159; // pi
        final isFront = angle < 1.5708; // < pi/2
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle),
          child: isFront
              ? _buildFront(isLocked)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(3.14159),
                  child: _buildBack(),
                ),
        );
      },
    );
  }

  Widget _buildFront(bool isLocked) {
    final d = widget.data;
    return GestureDetector(
      onTap: isLocked ? null : widget.onSelect,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 顶部：ID + 难度
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          d.sceneId,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHint),
                        ),
                      ),
                      DifficultyStars(level: d.difficulty, size: 14),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 场景图标
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.iconBgGradientStart, AppColors.iconBgGradientEnd],
                      ),
                    ),
                    child: Center(child: Text(d.emoji, style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(height: 10),
                  // 场景名称
                  Text(
                    d.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  // 描述
                  Text(
                    d.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // 元信息
                  Text('⏱️ ${d.duration}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  StatusBadge(status: d.status),
                  if (!isLocked) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _flip,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '查看背面 →',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 锁定遮罩
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.lock, size: 40, color: AppColors.textHint),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    final d = widget.data;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAFAFA), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 关键动作
            _SectionTitle(icon: '🎯', title: '关键动作'),
            const SizedBox(height: 6),
            ...d.keyActions.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.key + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(e.value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.5)),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            // 成功标准
            _InfoBlock(
              icon: '✅',
              title: '成功标准',
              text: d.successCriteria,
              bgColor: AppColors.successBg,
              borderColor: AppColors.success,
            ),
            const SizedBox(height: 8),
            // 失败信号
            _InfoBlock(
              icon: '⚠️',
              title: '失败信号',
              text: d.failureSignals,
              bgColor: AppColors.warningBg,
              borderColor: AppColors.warning,
            ),
            const SizedBox(height: 8),
            // 推荐 Skill
            if (d.recommendedSkills.isNotEmpty) ...[
              Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  const Text('推荐 Skill', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: d.recommendedSkills.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 10),
            // 返回正面按钮
            GestureDetector(
              onTap: _flip,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '← 返回正面',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String icon;
  final String title;
  final String text;
  final Color bgColor;
  final Color borderColor;
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.text,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: borderColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
