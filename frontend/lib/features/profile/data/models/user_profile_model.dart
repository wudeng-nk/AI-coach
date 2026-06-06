class UserProfileModel {
  final String id;
  final String phone;
  final String name;
  final String? avatar;
  final String role;
  final String? organization;

  UserProfileModel({
    required this.id,
    required this.phone,
    required this.name,
    this.avatar,
    required this.role,
    this.organization,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
    id: json['id'],
    phone: json['phone'],
    name: json['name'],
    avatar: json['avatar'],
    role: json['role'],
    organization: json['organization'],
  );
}

class TrainingStatsModel {
  final int totalSessions;
  final int completedSessions;
  final double? averageScore;
  final int? highestScore;
  final List<int> recentScores;

  TrainingStatsModel({
    required this.totalSessions,
    required this.completedSessions,
    this.averageScore,
    this.highestScore,
    this.recentScores = const [],
  });

  factory TrainingStatsModel.fromJson(Map<String, dynamic> json) => TrainingStatsModel(
    totalSessions: json['total_sessions'] ?? 0,
    completedSessions: json['completed_sessions'] ?? 0,
    averageScore: (json['average_score'] as num?)?.toDouble(),
    highestScore: json['highest_score'] as int?,
    recentScores: List<int>.from(json['recent_scores'] ?? []),
  );
}
