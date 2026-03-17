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
  static const String splash = '/splash';

  // Exam Categories & Questions Endpoints
  // Exam Categories endpoint is also available as /exam-categories for legacy, keeping both or updating.
  // The user requested /exam/categories so we add it. Note that examCategories is currently used by default exam fetches.
  static const String examCategories = '/exam/categories';
  static String examCategoryDetail(String categoryId) =>
      '/exam/categories/$categoryId';
  static String examCategoryQuestions(String categoryId) =>
      '/exam-categories/$categoryId/questions';

  // New Practice Flow Endpoints
  static String examSubCategories(String categoryId) =>
      '/exam/categories/$categoryId/subcategories';
  static String examTests(String subcategoryId) =>
      '/exam/categories/$subcategoryId/tests';
  static String testQuestions(String testId) => '/exam/tests/$testId/questions';

  /// API: GET /exam-categories/{id}/mock-exam?count=20
  static String mockExamQuestions(String categoryId) =>
      '/exam-categories/$categoryId/mock-exam';

  // Exam Results Endpoints
  static const String examResults = '/exam-results';
  static String examResultDetail(String id) => '/exam-results/$id';

  // Statistics Endpoints
  static const String statistics = '/statistics';
  static const String analytics = '/statistics/analytics';
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
  static const String aboutUs = '/info/about';
  static const String gdpr = '/info/gdpr';
  static const String policy = '/info/policy';

  // Search Endpoints
  static const String searchQuestions = '/search/questions';

  // Reports
  static const String reports = '/reports';

  // Workbooks
  static const String workbooks = '/workbooks';

  // Public Content
  static const String packages = '/packages';
  static String packageDetail(String packageId) => '/packages/$packageId';
  static const String activePackage = '/subscription/active-package';
  static const String signs = '/signs';
  static String signDetail(String signId) => '/signs/$signId';
  static const String swishCreate = '/swish/create';
  static String swishStatus(String paymentId) => '/swish/status/$paymentId';

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
