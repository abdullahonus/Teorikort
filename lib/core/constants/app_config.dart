class AppConfig {
  // Environment Configuration
  static const bool isDevelopment = true; // ✅ Development mode
  static const bool isProduction = false; // ❌ Production mode

  // Mock Fallback Configuration
  // Development'da mock fallback var, Production'da yok
  static const bool enableMockFallback = false;

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Debug Configuration
  static const bool enableApiLogging = isDevelopment;
  static const bool enableCrashlytics = isProduction;

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = isProduction;

  // App Information
  static const String appName = 'Driving Exam App';
  static const String appVersion = '1.0.0';

  // Get environment name
  static String get environmentName =>
      isDevelopment ? 'Development' : 'Production';

  // Get base URL
  static String get baseUrl {
    return 'https://teorikort.artratechs.com/api';
  }
}
