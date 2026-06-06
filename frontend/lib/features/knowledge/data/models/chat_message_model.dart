class ChatMessageModel {
  final String conversationId;
  final String answer;
  final List<String> sources;
  final String? category;
  final List<String> suggestions;

  ChatMessageModel({
    required this.conversationId,
    required this.answer,
    this.sources = const [],
    this.category,
    this.suggestions = const [],
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
    conversationId: json['conversation_id'],
    answer: json['answer'],
    sources: List<String>.from(json['sources'] ?? []),
    category: json['category'],
    suggestions: List<String>.from(json['suggestions'] ?? []),
  );
}

class HistoryItemModel {
  final String id;
  final String conversationId;
  final String question;
  final String answer;
  final List<String> sources;
  final String? category;
  final DateTime createdAt;

  HistoryItemModel({
    required this.id,
    required this.conversationId,
    required this.question,
    required this.answer,
    this.sources = const [],
    this.category,
    required this.createdAt,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) => HistoryItemModel(
    id: json['id'],
    conversationId: json['conversation_id'],
    question: json['question'],
    answer: json['answer'],
    sources: List<String>.from(json['sources'] ?? []),
    category: json['category'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
