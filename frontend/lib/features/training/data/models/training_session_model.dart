class TrainingSessionModel {
  final String id;
  final String customerId;
  final String status;
  final String startedAt;

  const TrainingSessionModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.startedAt,
  });

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) =>
      TrainingSessionModel(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        status: json['status'] as String,
        startedAt: json['started_at'] as String,
      );
}

class ChatMessageModel {
  final String id;
  final String role;
  final String content;
  final String? emotion;
  final String? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.emotion,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        emotion: json['emotion'] as String?,
        createdAt: json['created_at'] as String?,
      );
}

class SessionCreateResult {
  final TrainingSessionModel session;
  final ChatMessageModel openingMessage;

  const SessionCreateResult({
    required this.session,
    required this.openingMessage,
  });

  factory SessionCreateResult.fromJson(Map<String, dynamic> json) =>
      SessionCreateResult(
        session:
            TrainingSessionModel.fromJson(json['session'] as Map<String, dynamic>),
        openingMessage: ChatMessageModel.fromJson(
            json['opening_message'] as Map<String, dynamic>),
      );
}

class ChatResult {
  final ChatMessageModel userMessage;
  final ChatMessageModel customerMessage;
  final bool isPurchased;
  final bool sessionEnded;

  const ChatResult({
    required this.userMessage,
    required this.customerMessage,
    required this.isPurchased,
    required this.sessionEnded,
  });

  factory ChatResult.fromJson(Map<String, dynamic> json) => ChatResult(
        userMessage: ChatMessageModel.fromJson(
            json['user_message'] as Map<String, dynamic>),
        customerMessage: ChatMessageModel.fromJson(
            json['customer_message'] as Map<String, dynamic>),
        isPurchased: json['is_purchased'] as bool? ?? false,
        sessionEnded: json['session_ended'] as bool? ?? false,
      );
}
