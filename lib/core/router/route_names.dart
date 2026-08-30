class RouteNames {
  RouteNames._();

  // Root & Auth
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Main Bottom Navigation / Home
  static const String home = '/';
  static const String doctors = '/doctors';
  static const String doctorDetail = '/doctors/:id';
  static const String appointments = '/appointments';
  static const String consultations = '/consultations';
  static const String consultationRoom = '/consultations/:id/room';

  // Pharmacy
  static const String pharmacy = '/pharmacy';
  static const String medicineDetail = '/pharmacy/medicine/:slug';
  static const String cart = '/pharmacy/cart';
  static const String checkout = '/pharmacy/checkout';
  static const String orders = '/pharmacy/orders';

  // Chatbot & AI Assistant
  static const String chatbot = '/chatbot';

  // Profile & Settings
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}

