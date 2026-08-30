class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'AppException(message: $message, statusCode: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Please check your internet connection.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Access denied.'])
      : super(statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.'])
      : super(statusCode: 404);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.data})
      : super(statusCode: 422);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Internal server error occurred.'])
      : super(statusCode: 500);
}

