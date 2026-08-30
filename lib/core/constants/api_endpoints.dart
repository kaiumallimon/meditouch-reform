import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Environment-aware Base URL
  static String get baseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (customUrl.isNotEmpty) return customUrl;

    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:8000/api/v1';
    }
  }

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Pharmacy & Medicines
  static const String medicines = '/pharmacy/medicines';
  static const String medicineDetail = '/pharmacy/medicines/';
  static const String categories = '/pharmacy/categories';
  static const String cart = '/pharmacy/cart';
  static const String orders = '/pharmacy/orders';

  // Doctors & Consultations
  static const String doctors = '/doctors';
  static const String doctorTimeslots = '/doctors/timeslots';
  static const String appointments = '/appointments';
  static const String consultations = '/consultations';

  // AI Assistant & Chatbot
  static const String chatStream = '/chat/stream';
  static const String chatSessions = '/chat/sessions';
  static String submitClarification(String sessionId, String clarificationId) =>
      '/chat/sessions/$sessionId/clarifications/$clarificationId/submit';

  // Payments & Notifications
  static const String bkashCreate = '/payments/bkash/create';
  static const String notifications = '/notifications';
}

