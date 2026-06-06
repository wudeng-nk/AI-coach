import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/features/home/presentation/bloc/home_bloc.dart';
import 'package:ai_coach/features/home/presentation/widgets/welcome_section.dart';
import 'package:ai_coach/features/home/presentation/widgets/recommend_card.dart';
import 'package:ai_coach/features/home/presentation/widgets/weekly_data_card.dart';
import 'package:ai_coach/features/home/presentation/widgets/hot_scenes_card.dart';
import 'package:ai_coach/features/home/presentation/widgets/floating_tip.dart';

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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is HomeError) {
          return Scaffold(
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
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(HomeLoadRequested());
                  },
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // 顶部导航栏
                      _TopNavBar(userName: data.user.name),
                      // 欢迎区
                      WelcomeSection(
                        userName: data.user.name,
                        consecutiveDays: data.user.consecutiveDays,
                        todayCompleted: data.user.todayCompleted,
                      ),
                      const SizedBox(height: 8),
                      // 推荐训练卡片
                      RecommendCard(
                        recommendation: data.recommendation,
                        onStart: () {
                          context.push('/training/chat/${data.recommendation.parentId}');
                        },
                      ),
                      // 本周数据
                      WeeklyDataCard(
                        data: data.weeklyData,
                        onTap: () => context.go('/profile'),
                      ),
                      // 热门场景
                      HotScenesCard(
                        scenes: data.hotScenes,
                        onSceneTap: (sceneId) {
                          context.go('/training');
                        },
                      ),
                      const SizedBox(height: 100), // 底部导航空间 + 浮窗空间
                    ],
                  ),
                ),
                // 刘总浮窗
                FloatingTip(
                  message: data.floatingTip.message,
                  hasBadge: data.floatingTip.hasBadge,
                  badgeCount: data.floatingTip.badgeCount,
                ),
              ],
            ),
          );
        }

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}

class _TopNavBar extends StatelessWidget {
  final String userName;
  const _TopNavBar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            // 用户头像
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLightest,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0] : '?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // 消息图标
            Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 24, color: AppColors.textSecondary),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const Icon(Icons.settings_outlined, size: 24, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
