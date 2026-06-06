class ReportModel {
  final String id;
  final String sessionId;
  final double overallScore;
  final Map<String, ScoreDetail> scores;
  final List<String> highlights;
  final List<String> improvements;
  final List<DialogueAnnotation> dialogueAnnotations;
  final String createdAt;

  const ReportModel({
    required this.id,
    required this.sessionId,
    required this.overallScore,
    required this.scores,
    required this.highlights,
    required this.improvements,
    required this.dialogueAnnotations,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        id: json['id'] as String,
        sessionId: json['session_id'] as String,
        overallScore: (json['overall_score'] as num).toDouble(),
        scores: _parseScores(json['scores'] as Map<String, dynamic>),
        highlights: (json['highlights'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        improvements: (json['improvements'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        dialogueAnnotations: ((json['dialogue_annotations'] ?? json['annotations']) as List<dynamic>)
            .map((e) =>
                DialogueAnnotation.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['created_at'] as String,
      );

  static Map<String, ScoreDetail> _parseScores(Map<String, dynamic> json) {
    return json.map((key, value) {
      final map = value as Map<String, dynamic>;
      return MapEntry(
        key,
        ScoreDetail(
          score: (map['score'] as num).toDouble(),
          comment: map['comment'] as String? ?? '',
        ),
      );
    });
  }
}

class ScoreDetail {
  final double score;
  final String comment;

  const ScoreDetail({
    required this.score,
    required this.comment,
  });
}

class DialogueAnnotation {
  final int messageIndex;
  final String role;
  final String content;
  final String? feedback;

  const DialogueAnnotation({
    required this.messageIndex,
    required this.role,
    required this.content,
    this.feedback,
  });

  factory DialogueAnnotation.fromJson(Map<String, dynamic> json) =>
      DialogueAnnotation(
        messageIndex: json['message_index'] as int,
        role: json['role'] as String,
        content: json['content'] as String,
        feedback: json['feedback'] as String?,
      );
}
