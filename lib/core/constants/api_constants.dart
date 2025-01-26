class ApiConstants {
  static const String baseUrl = 'https://api.teorikort.se/api/v1';
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // API Headers
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest', 
  };

  // API Response Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
}
