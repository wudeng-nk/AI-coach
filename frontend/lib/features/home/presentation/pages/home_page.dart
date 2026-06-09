import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/features/home/presentation/bloc/home_bloc.dart';
import 'package:ai_coach/features/home/presentation/widgets/welcome_section.dart';
import 'package:ai_coach/features/home/presentation/widgets/weekly_data_card.dart';
import 'package:ai_coach/features/home/presentation/widgets/score_trend_card.dart';
import 'package:ai_coach/features/home/presentation/widgets/scene_progress_card.dart';
import 'package:ai_coach/features/home/presentation/widgets/recent_training_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F5F5),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is HomeError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HomeBloc>().add(HomeLoadRequested()),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeLoaded) {
          final data = state.data;
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(HomeLoadRequested());
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 蓝色渐变欢迎横幅（含顶部标题栏）
                  WelcomeBanner(
                    userName: data.user.name,
                    consecutiveDays: data.user.consecutiveDays,
                  ),
                  const SizedBox(height: 12),
                  // 本周数据
                  WeeklyDataCard(data: data.weeklyData),
                  const SizedBox(height: 12),
                  // 得分趋势
                  ScoreTrendCard(trend: data.scoreTrend),
                  const SizedBox(height: 12),
                  // 场景完成度
                  SceneProgressCard(scenes: data.sceneProgress),
                  const SizedBox(height: 16),
                  // 开始训练按钮
                  _TrainingButton(onTap: () => context.push('/training/hall')),
                  const SizedBox(height: 12),
                  // 最近训练
                  RecentTrainingCard(trainings: data.recentTrainings),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}

class _TrainingButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TrainingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E40AF).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text(
                    '开始训练',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
