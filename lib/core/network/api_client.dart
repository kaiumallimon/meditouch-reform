import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/errors/app_exception.dart';
import 'package:meditouch/core/network/auth_interceptor.dart';
import 'package:meditouch/core/storage/secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(storage));
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    if (error.error is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return const NetworkException('Network connection failed. Please check internet connection.');
    }

    final response = error.response;
    if (response == null) {
      return NetworkException(error.message ?? 'Unknown connection error.');
    }

    final statusCode = response.statusCode;
    final dynamic responseData = response.data;
    String errorMessage = 'An unexpected error occurred.';

    if (responseData is Map<String, dynamic>) {
      errorMessage = responseData['detail']?.toString() ??
          responseData['message']?.toString() ??
          errorMessage;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(errorMessage, data: responseData);
      case 401:
        return UnauthorizedException(errorMessage);
      case 403:
        return ForbiddenException(errorMessage);
      case 404:
        return NotFoundException(errorMessage);
      case 422:
        return ValidationException(errorMessage, data: responseData);
      case 500:
      case 502:
      case 503:
        return ServerException(errorMessage);
      default:
        return AppException(errorMessage, statusCode: statusCode, data: responseData);
    }
  }
}

