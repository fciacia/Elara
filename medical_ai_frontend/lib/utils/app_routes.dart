class AppRoutes {
  // Authentication Routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main App Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  
  // Document Management Routes
  static const String documents = '/documents';
  static const String documentUpload = '/documents/upload';
  static const String documentViewer = '/documents/viewer';
  static const String documentAnalysis = '/documents/analysis';
  
  // Chat & Query Routes
  static const String chat = '/chat';
  static const String chatHistory = '/chat/history';
  static const String savedQueries = '/chat/saved';
  
  // Profile & Settings Routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String language = '/settings/language';
  static const String notifications = '/settings/notifications';
  
  // Role-Specific Routes
  static const String patientDashboard = '/patient/dashboard';
  static const String doctorDashboard = '/doctor/dashboard';
  static const String adminDashboard = '/admin/dashboard';
  
  // Analytics & Reports Routes
  static const String analytics = '/analytics';
  static const String reports = '/reports';
  static const String patientJourney = '/patient/journey';
  static const String riskAlerts = '/alerts/risks';
  
  // Help & Support Routes
  static const String help = '/help';
  static const String about = '/about';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
}

// Route Parameter Keys
class RouteParams {
  static const String documentId = 'documentId';
  static const String chatId = 'chatId';
  static const String patientId = 'patientId';
  static const String userId = 'userId';
  static const String role = 'role';
  static const String language = 'language';
}
