import 'package:dio/dio.dart';
import 'package:meditouch/core/storage/secure_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear token on 401 Unauthorized
      await _storage.clearAll();
    }
    return handler.next(err);
  }
}

