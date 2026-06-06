import 'package:dio/dio.dart';

class ProfileRemoteDataSource {
  final Dio _dio;
  ProfileRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/v1/users/me');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? avatar,
    String? organization,
  }) async {
    final response = await _dio.put('/v1/users/me', data: {
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (organization != null) 'organization': organization,
    });
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final response = await _dio.get('/v1/training/statistics');
    return response.data['data'];
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.put('/v1/users/me/password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }
}
