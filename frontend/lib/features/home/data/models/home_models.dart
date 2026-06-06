/// 首页数据模型 — 纯 Dart 类，后端 API 就绪后添加 JSON 序列化
class HomeData {
  final UserData user;
  final RecommendationData recommendation;
  final WeeklyData weeklyData;
  final List<HotScene> hotScenes;
  final FloatingTipData floatingTip;

  HomeData({
    required this.user,
    required this.recommendation,
    required this.weeklyData,
    required this.hotScenes,
    required this.floatingTip,
  });
}

class UserData {
  final String name;
  final String? avatarUrl;
  final int consecutiveDays;
  final int todayCompleted;

  UserData({
    required this.name,
    this.avatarUrl,
    this.consecutiveDays = 0,
    this.todayCompleted = 0,
  });
}

class RecommendationData {
  final String sceneId;
  final String sceneName;
  final String parentId;
  final String parentName;
  final String reason;
  final int difficulty;
  final String estimatedDuration;

  RecommendationData({
    required this.sceneId,
    required this.sceneName,
    required this.parentId,
    required this.parentName,
    required this.reason,
    required this.difficulty,
    required this.estimatedDuration,
  });
}

class WeeklyData {
  final int completedCount;
  final int completedTrend;
  final int averageScore;
  final int scoreTrend;
  final int passRate;
  final int passRateTrend;

  WeeklyData({
    required this.completedCount,
    required this.completedTrend,
    required this.averageScore,
    required this.scoreTrend,
    required this.passRate,
    required this.passRateTrend,
  });
}

class HotScene {
  final String sceneId;
  final String sceneName;
  final String emoji;
  final int popularity;

  HotScene({
    required this.sceneId,
    required this.sceneName,
    required this.emoji,
    required this.popularity,
  });
}

class FloatingTipData {
  final String message;
  final bool hasBadge;
  final int? badgeCount;
  final String type;

  FloatingTipData({
    required this.message,
    this.hasBadge = false,
    this.badgeCount,
    required this.type,
  });
}
