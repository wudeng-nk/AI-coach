import 'models/home_models.dart';

/// 首页 mock 数据 — 后端 API 就绪后替换为真实网络请求
class HomeMockData {
  static HomeData get data => HomeData(
    user: UserData(name: '张顾问', consecutiveDays: 5, todayCompleted: 2),
    weeklyData: WeeklyData(
      completedCount: 8,
      averageScore: 76,
    ),
    scoreTrend: [
      ScoreTrendItem(day: '周一', score: 72),
      ScoreTrendItem(day: '周二', score: 75),
      ScoreTrendItem(day: '周三', score: 70),
      ScoreTrendItem(day: '周四', score: 78),
      ScoreTrendItem(day: '周五', score: 76),
      ScoreTrendItem(day: '周六', score: 80),
      ScoreTrendItem(day: '周日', score: 82),
    ],
    sceneProgress: [
      SceneProgress(name: '电话邀约', percentage: 0.8),
      SceneProgress(name: '到店咨询', percentage: 0.6),
      SceneProgress(name: '价格异议', percentage: 0.4),
    ],
    recentTrainings: [
      RecentTraining(title: '电话邀约-焦虑型', score: 82, timeAgo: '2小时前'),
      RecentTraining(title: '到店咨询-迷茫型', score: 68, timeAgo: '昨天'),
    ],
  );
}
