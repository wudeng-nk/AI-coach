import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post('/v1/auth/register', data: {
      'phone': phone,
      'password': password,
      'name': name,
    });
    return response.data['data'];
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post('/v1/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    return response.data['data'];
  }
}
