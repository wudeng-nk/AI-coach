import 'package:dio/dio.dart';

class KnowledgeRemoteDataSource {
  final Dio _dio;

  KnowledgeRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> chat({
    required String question,
    String? conversationId,
  }) async {
    final response = await _dio.post('/v1/knowledge/chat', data: {
      'question': question,
      ...?conversationId != null ? {'conversation_id': conversationId} : null,
    });
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getHistory({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get('/v1/knowledge/history', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    return response.data['data'];
  }

  Future<void> submitFeedback({
    required String chatId,
    required String feedback,
  }) async {
    await _dio.post('/v1/knowledge/feedback', data: {
      'chat_id': chatId,
      'feedback': feedback,
    });
  }
}
