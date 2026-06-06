import 'models/home_models.dart';

/// 首页 mock 数据 — 后端 API 就绪后替换为真实网络请求
class HomeMockData {
  static HomeData get data => HomeData(
    user: UserData(name: '张顾问', consecutiveDays: 5, todayCompleted: 2),
    recommendation: RecommendationData(
      sceneId: 'S-03',
      sceneName: '异议处理',
      parentId: 'P-03',
      parentName: '理性型爸爸',
      reason: '上次你在价格异议上有进步空间，建议再练习一次',
      difficulty: 5,
      estimatedDuration: '3-8 分钟',
    ),
    weeklyData: WeeklyData(
      completedCount: 12,
      completedTrend: 3,
      averageScore: 82,
      scoreTrend: 5,
      passRate: 75,
      passRateTrend: -5,
    ),
    hotScenes: [
      HotScene(sceneId: 'S-01', sceneName: '破冰', emoji: '🤝', popularity: 95),
      HotScene(sceneId: 'S-02', sceneName: '需求挖掘', emoji: '🔍', popularity: 88),
      HotScene(sceneId: 'S-06', sceneName: '签约', emoji: '✍️', popularity: 82),
      HotScene(sceneId: 'S-03', sceneName: '异议处理', emoji: '💬', popularity: 76),
    ],
    floatingTip: FloatingTipData(
      message: '今天状态不错！建议挑战「异议处理」场景，上次你在价格异议上有进步空间 💪',
      hasBadge: true,
      badgeCount: 1,
      type: 'suggestion',
    ),
  );
}
