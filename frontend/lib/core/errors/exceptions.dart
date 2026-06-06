class AppException implements Exception {
  final String message;
  final int? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({String? message}) : super(message: message ?? '网络连接失败，请检查网络');
}

class AuthException extends AppException {
  AuthException({String? message}) : super(message: message ?? '认证失败，请重新登录');
}

class ServerException extends AppException {
  ServerException({String? message}) : super(message: message ?? '服务器错误，请稍后重试');
}
