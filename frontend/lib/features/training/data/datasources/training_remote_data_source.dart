import 'package:dio/dio.dart';
import 'package:ai_coach/features/training/data/models/customer_model.dart';
import 'package:ai_coach/features/training/data/models/training_session_model.dart';
import 'package:ai_coach/features/training/data/models/report_model.dart';

class TrainingRemoteDataSource {
  final Dio _dio;

  TrainingRemoteDataSource(this._dio);

  /// GET /api/v1/training/customers
  Future<List<CustomerModel>> getCustomers() async {
    final response = await _dio.get('/v1/training/customers');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/training/customers/:id
  Future<CustomerDetailModel> getCustomerDetail(String customerId) async {
    final response =
        await _dio.get('/v1/training/customers/$customerId');
    return CustomerDetailModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// POST /api/v1/training/sessions
  Future<SessionCreateResult> createSession(String customerId) async {
    final response = await _dio.post(
      '/v1/training/sessions',
      data: {'customer_id': customerId},
    );
    return SessionCreateResult.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// POST /api/v1/training/sessions/:id/chat
  Future<ChatResult> sendMessage(String sessionId, String content) async {
    final response = await _dio.post(
      '/v1/training/sessions/$sessionId/chat',
      data: {'content': content},
    );
    return ChatResult.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// POST /api/v1/training/sessions/:id/end
  Future<void> endSession(String sessionId) async {
    await _dio.post('/v1/training/sessions/$sessionId/end', data: {});
  }

  /// GET /api/v1/training/sessions/:id/report
  Future<ReportModel> getReport(String sessionId) async {
    final response =
        await _dio.get('/v1/training/sessions/$sessionId/report');
    return ReportModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
