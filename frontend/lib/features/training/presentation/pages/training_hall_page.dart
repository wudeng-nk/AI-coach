import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/features/training/presentation/bloc/training_hall_bloc.dart';
import 'package:ai_coach/features/training/presentation/widgets/scene_card.dart';
import 'package:ai_coach/shared/widgets/gradient_avatar.dart';
import 'package:ai_coach/shared/widgets/status_badge.dart';

class TrainingHallPage extends StatelessWidget {
  const TrainingHallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrainingHallBloc()..add(const TrainingCustomersLoadRequested()),
      child: const _TrainingHallView(),
    );
  }
}

class _TrainingHallView extends StatelessWidget {
  const _TrainingHallView();

  // Mock 场景数据 — 后续从后端 API 获取
  List<SceneCardData> _buildSceneCards() {
    return const [
      SceneCardData(
        sceneId: 'S-01',
        name: '破冰',
        description: '建立信任，让家长开口',
        difficulty: 2,
        duration: '3-5 分钟',
        emoji: '🤝',
        status: SceneStatus.completed,
        completedCount: 12,
        keyActions: [
          '热情迎接，称呼得体',
          '观察家长状态，调整语气',
          '找到共情切入点',
          '引导家长开口说孩子情况',
        ],
        successCriteria: '家长主动说出孩子 2 个以上学习信息',
        failureSignals: '家长保持防备，不愿分享',
        recommendedSkills: ['SK-01'],
      ),
      SceneCardData(
        sceneId: 'S-02',
        name: '需求挖掘',
        description: '识别痛点，判断客户类型',
        difficulty: 4,
        duration: '10-15 分钟',
        emoji: '🔍',
        status: SceneStatus.inProgress,
        completedCount: 8,
        keyActions: [
          '开放式提问',
          '追问具体场景',
          '倾听+共情+复述',
          '识别客户类型',
          '判断决策链',
        ],
        successCriteria: '确认年级+薄弱科目+核心焦虑+预算区间',
        failureSignals: '只聊表面需求，没识别客户类型',
        recommendedSkills: ['SK-02', 'SK-03'],
      ),
      SceneCardData(
        sceneId: 'S-03',
        name: '异议处理',
        description: '转化异议为购买动机',
        difficulty: 5,
        duration: '3-8 分钟',
        emoji: '💬',
        status: SceneStatus.locked,
        keyActions: [
          '共情承认',
          '价值重构',
          '证据支撑',
          '选择收口',
        ],
        successCriteria: '家长停止反驳，开始问具体问题',
        failureSignals: '跟家长争论，家长明显不耐烦',
        recommendedSkills: ['SK-05', 'SK-06', 'SK-07'],
      ),
      SceneCardData(
        sceneId: 'S-04',
        name: '首访',
        description: '推荐方案，引导体验',
        difficulty: 3,
        duration: '15-20 分钟',
        emoji: '🏢',
        status: SceneStatus.locked,
        keyActions: [
          '需求→产品匹配',
          '展示差异化',
          '现场体验引导',
          '结合测试结果解读价值',
        ],
        successCriteria: '家长同意让孩子做AI诊断测试',
        failureSignals: '推荐与需求不匹配',
        recommendedSkills: ['SK-02', 'SK-04'],
      ),
      SceneCardData(
        sceneId: 'S-05',
        name: '跟进',
        description: '价值触达，推动决策',
        difficulty: 4,
        duration: '5-10 分钟',
        emoji: '📞',
        status: SceneStatus.locked,
        keyActions: [
          '跟进时机判断',
          '价值型跟进',
          '找到犹豫真实原因',
          '制造合理紧迫感',
          '给出明确的下一步行动',
        ],
        successCriteria: '家长回复积极，同意二次到店',
        failureSignals: '家长不接电话，每次都说"再想想"',
        recommendedSkills: ['SK-05', 'SK-08'],
      ),
      SceneCardData(
        sceneId: 'S-06',
        name: '签约',
        description: '锁定成交，处理最后顾虑',
        difficulty: 4,
        duration: '10-15 分钟',
        emoji: '✍️',
        status: SceneStatus.locked,
        keyActions: [
          '价值总结',
          '处理最后顾虑',
          '限时策略',
          '付款引导',
          '签约后承诺',
        ],
        successCriteria: '家长完成付款/明确签约时间',
        failureSignals: '过度逼单让家长反感',
        recommendedSkills: ['SK-05', 'SK-09'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scenes = _buildSceneCards();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('训练大厅'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // 刘总提示条
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.primaryLightest,
            child: Row(
              children: [
                GradientAvatar.squirrel(size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '从破冰开始，循序渐进！完成当前场景即可解锁下一个',
                    style: TextStyle(fontSize: 13, color: AppColors.primary.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ),
          // 场景卡片网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: scenes.length,
              itemBuilder: (context, index) {
                final scene = scenes[index];
                return SceneCard(
                  data: scene,
                  onSelect: () {
                    // 跳转到家长选择页（暂用现有 chat 页面）
                    context.push('/training/chat/${scene.sceneId}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
