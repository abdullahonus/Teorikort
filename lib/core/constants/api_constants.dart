import 'app_config.dart';

class ApiConstants {
  static String get baseUrl => AppConfig.baseUrl;

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Home Screen Endpoints
  static const String home = '/home';
  static const String dailyTips = '/daily-tips/today';

  // Exam Categories & Questions Endpoints
  static const String examCategories = '/exam-categories';
  static String examCategoryDetail(String categoryId) =>
      '/exam-categories/$categoryId';
  static String examCategoryQuestions(String categoryId) =>
      '/exam-categories/$categoryId/questions';

  /// API: GET /exam-categories/{id}/mock-exam?count=20
  static String mockExamQuestions(String categoryId) =>
      '/exam-categories/$categoryId/mock-exam';

  // Exam Results Endpoints
  static const String examResults = '/exam-results';

  // Statistics Endpoints
  static const String statistics = '/statistics';
  static String categoryStatistics(String categoryId) =>
      '/statistics/categories/$categoryId';

  // Leaderboard Endpoints
  static const String leaderboard = '/leaderboard';
  static const String myRank = '/leaderboard/my-rank';

  // Topics & Educational Content Endpoints
  static const String topics = '/topics';
  static String topicDetail(String topicId) => '/topics/$topicId';
  static String subtopicDetail(String topicId, String subtopicId) =>
      '/topics/$topicId/subtopics/$subtopicId';

  // User Profile Endpoints
  static const String userProfile = '/profile';
  static const String userProfilePhoto = '/profile/photo';
  static const String userSettings = '/user/settings';

  // Search Endpoints
  static const String searchQuestions = '/search/questions';

  // Reports
  static const String reports = '/reports';

  // Workbooks
  static const String workbooks = '/workbooks';

  // Public Content
  static const String packages = '/packages';
  static String packageDetail(String packageId) => '/packages/$packageId';
  static const String signs = '/signs';
  static String signDetail(String signId) => '/signs/$signId';

  // API Headers
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
    'app': 'taxi',
  };

  // Auth Headers with token
  static Map<String, String> authHeaders(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };

  // Multipart Headers for file upload
  static Map<String, String> multipartHeaders(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // API Response Codes
  static const int success = 100; // Backend uses 100 for success
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;
  static const int serverError = 500;

  // Default Parameters
  static const String defaultLanguage = 'en';
  static const int defaultLimit = 10;
  static const int defaultPage = 1;
}
