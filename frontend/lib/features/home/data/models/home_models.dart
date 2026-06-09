/// 首页数据模型 — 纯 Dart 类，后端 API 就绪后添加 JSON 序列化
class HomeData {
  final UserData user;
  final WeeklyData weeklyData;
  final List<ScoreTrendItem> scoreTrend;
  final List<SceneProgress> sceneProgress;
  final List<RecentTraining> recentTrainings;

  HomeData({
    required this.user,
    required this.weeklyData,
    required this.scoreTrend,
    required this.sceneProgress,
    required this.recentTrainings,
  });
}

class UserData {
  final String name;
  final int consecutiveDays;
  final int todayCompleted;

  UserData({
    required this.name,
    this.consecutiveDays = 0,
    this.todayCompleted = 0,
  });
}

class WeeklyData {
  final int completedCount;
  final int averageScore;

  WeeklyData({
    required this.completedCount,
    required this.averageScore,
  });
}

class ScoreTrendItem {
  final String day;
  final int score;

  ScoreTrendItem({required this.day, required this.score});
}

class SceneProgress {
  final String name;
  final double percentage;

  SceneProgress({required this.name, required this.percentage});
}

class RecentTraining {
  final String title;
  final int score;
  final String timeAgo;

  RecentTraining({
    required this.title,
    required this.score,
    required this.timeAgo,
  });
}
