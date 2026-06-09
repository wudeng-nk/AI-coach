import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ai_coach/features/auth/presentation/pages/login_page.dart';
import 'package:ai_coach/features/auth/presentation/pages/register_page.dart';
import 'package:ai_coach/features/home/presentation/pages/home_page.dart';
import 'package:ai_coach/features/training/presentation/pages/training_hall_page.dart';
import 'package:ai_coach/features/training/presentation/pages/parent_selection_page.dart';
import 'package:ai_coach/features/training/presentation/pages/training_chat_page.dart';
import 'package:ai_coach/features/training/presentation/pages/training_report_page.dart';
import 'package:ai_coach/features/data/presentation/pages/data_page.dart';
import 'package:ai_coach/features/profile/presentation/pages/profile_page.dart';
import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/shared/widgets/gamepad_tab_icon.dart';
import 'package:ai_coach/shared/widgets/chart_tab_icon.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final authBloc = context.read<AuthBloc>();
    final isLoggedIn = authBloc.state is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) return '/auth/login';
    if (isLoggedIn && isAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (_, __) => const RegisterPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (_, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomePage()),
        GoRoute(path: '/data', builder: (_, __) => const DataPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
    GoRoute(
      path: '/training/hall',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const TrainingHallPage(),
    ),
    GoRoute(
      path: '/training/parents/:sceneId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => ParentSelectionPage(
        sceneId: state.pathParameters['sceneId']!,
      ),
    ),
    GoRoute(
      path: '/training/chat/:customerId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => TrainingChatPage(
        customerId: state.pathParameters['customerId']!,
      ),
    ),
    GoRoute(
      path: '/training/report/:sessionId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => TrainingReportPage(
        sessionId: state.pathParameters['sessionId']!,
      ),
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/data') return 1;
    if (location == '/profile') return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) {
            switch (i) {
              case 0: context.go('/');
              case 1: context.go('/data');
              case 2: context.go('/profile');
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: GamepadTabIcon(isActive: false),
              activeIcon: GamepadTabIcon(isActive: true),
              label: '训练',
            ),
            const BottomNavigationBarItem(
              icon: ChartTabIcon(isActive: false),
              activeIcon: ChartTabIcon(isActive: true),
              label: '数据',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, color: const Color(0xFF9CA3AF)),
              activeIcon: Icon(Icons.person, color: const Color(0xFF1E40AF)),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
