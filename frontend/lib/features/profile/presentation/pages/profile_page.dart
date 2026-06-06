import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ai_coach/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_coach/features/profile/presentation/bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileBloc>().add(ProfileLoadRequested()),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          if (state is ProfileLoaded) {
            final user = state.user;
            final stats = state.stats;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(ProfileLoadRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              user.name.isNotEmpty ? user.name[0] : '?',
                              style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  _maskPhone(user.phone),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _roleLabel(user.role),
                                    style: const TextStyle(color: AppColors.primary, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Training stats card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('训练统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatItem(
                                label: '训练次数',
                                value: '${stats.totalSessions}',
                              ),
                              _StatItem(
                                label: '已完成',
                                value: '${stats.completedSessions}',
                              ),
                              _StatItem(
                                label: '平均分',
                                value: stats.averageScore != null ? stats.averageScore!.toStringAsFixed(1) : '-',
                              ),
                              _StatItem(
                                label: '最高分',
                                value: stats.highestScore?.toString() ?? '-',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recent scores trend
                  if (stats.recentScores.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('最近成绩', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: stats.recentScores.reversed.map((score) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text('$score', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                          const SizedBox(height: 4),
                                          Container(
                                            height: (score / 100 * 80).clamp(8.0, 80.0),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.7),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Menu items
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('训练历史'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/training'),
                        ),
                        const Divider(height: 1, indent: 16),
                        ListTile(
                          leading: const Icon(Icons.lock_outline),
                          title: const Text('修改密码'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout button
                  OutlinedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(ProfileLogoutRequested());
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      context.go('/auth/login');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('退出登录'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin': return '管理员';
      case 'manager': return '主管';
      default: return '课程顾问';
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: '原密码')),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: '新密码')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              try {
                final ds = ProfileRemoteDataSource(
                  dioClient.dio,
                );
                await ds.changePassword(oldPassword: oldCtrl.text, newPassword: newCtrl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密码修改成功')));
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('修改失败: $e')));
                }
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
