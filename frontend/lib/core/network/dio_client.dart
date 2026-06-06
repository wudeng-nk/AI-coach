import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static const String baseUrl = '/api';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  late final Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(_AuthInterceptor());
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(DioClient.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try refresh token
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(DioClient.refreshTokenKey);
      if (refreshToken != null) {
        try {
          final dio = Dio();
          final response = await dio.post(
            '${DioClient.baseUrl}/v1/auth/refresh',
            data: {'refresh_token': refreshToken},
          );
          final data = response.data['data'];
          await prefs.setString(DioClient.accessTokenKey, data['access_token']);
          await prefs.setString(DioClient.refreshTokenKey, data['refresh_token']);
          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer ${data['access_token']}';
          final retryResponse = await dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          // Refresh failed, clear tokens
          await prefs.remove(DioClient.accessTokenKey);
          await prefs.remove(DioClient.refreshTokenKey);
        }
      }
    }
    handler.next(err);
  }
}

final dioClient = DioClient();
