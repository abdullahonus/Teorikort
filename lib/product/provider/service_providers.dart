import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_manager.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/repository/i_home_repository.dart';
import '../../data/repository/home_repository_impl.dart';
import '../../domain/repository/i_profile_repository.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../domain/repository/i_exam_repository.dart';
import '../../data/repository/exam_repository_impl.dart';
import '../../domain/repository/i_statistics_repository.dart';
import '../../data/repository/statistics_repository_impl.dart';
import '../../domain/repository/i_topic_repository.dart';
import '../../data/repository/topic_repository_impl.dart';
import '../../domain/repository/i_workbook_repository.dart';
import '../../data/repository/workbook_repository_impl.dart';
import '../../domain/repository/i_leaderboard_repository.dart';
import '../../data/repository/leaderboard_repository_impl.dart';
import '../../domain/repository/i_search_repository.dart';
import '../../data/repository/search_repository_impl.dart';
import '../../features/user/data/repositories/user_repository.dart';
import '../../features/home/data/services/home_service.dart';
import '../../features/home/data/services/daily_tip_service.dart';
import '../../features/exam/data/services/exam_service.dart';
import '../../features/exam/data/services/category_service.dart';
import '../../features/exam/data/services/mock_exam_service.dart';
import '../../features/exam/data/services/exam_result_service.dart';
import '../../features/quiz/data/services/quiz_service.dart';
import '../../features/topics/data/services/topic_service.dart';
import '../../features/topics/data/services/traffic_sign_service.dart';
import '../../features/profile/data/services/profile_service.dart';
import '../../features/leaderboard/data/services/leaderboard_service.dart';
import '../../features/statistics/data/services/statistics_service.dart';
import '../../features/search/data/services/search_service.dart';
import '../../features/workbook/data/services/workbook_service.dart';
import '../../features/packages/data/services/package_service.dart';
import '../../features/reports/data/services/report_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// NETWORK LAYER
// Tüm servisler için tek NetworkManager instance'ı.
// ──────────────────────────────────────────────────────────────────────────────

final networkManagerProvider = Provider<NetworkManager>((ref) {
  final manager = NetworkManager();
  ref.onDispose(manager.dispose);
  return manager;
});

// ──────────────────────────────────────────────────────────────────────────────
// CORE SERVICES
// ──────────────────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// ──────────────────────────────────────────────────────────────────────────────
// REPOSITORIES
// Spec DI FLOW: Repository receives Service via ref.read(xxxServiceProvider).
// ──────────────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthRepositoryImpl(authService);
});

final homeRepositoryProvider = Provider<IHomeRepository>((ref) {
  final homeService = ref.read(homeServiceProvider);
  final dailyTipService = ref.read(dailyTipServiceProvider);
  return HomeRepositoryImpl(homeService, dailyTipService);
});

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final userRepository = ref.read(userRepositoryServiceProvider);
  return ProfileRepositoryImpl(userRepository);
});

final examRepositoryProvider = Provider<IExamRepository>((ref) {
  final examService = ref.read(examServiceProvider);
  final quizService = ref.read(quizServiceProvider);
  final mockExamService = ref.read(mockExamServiceProvider);

  return ExamRepositoryImpl(examService, quizService, mockExamService);
});

final statisticsRepositoryProvider = Provider<IStatisticsRepository>((ref) {
  final statisticsService = ref.read(statisticsServiceProvider);
  return StatisticsRepositoryImpl(statisticsService);
});

final topicRepositoryProvider = Provider<ITopicRepository>((ref) {
  final topicService = ref.read(topicServiceProvider);
  final trafficSignService = ref.read(trafficSignServiceProvider);
  return TopicRepositoryImpl(topicService: topicService, trafficSignService: trafficSignService);
});

final workbookRepositoryProvider = Provider<IWorkbookRepository>((ref) {
  final workbookService = ref.read(workbookServiceProvider);
  return WorkbookRepositoryImpl(workbookService);
});

final leaderboardRepositoryProvider = Provider<ILeaderboardRepository>((ref) {
  final leaderboardService = ref.read(leaderboardServiceProvider);
  return LeaderboardRepositoryImpl(leaderboardService);
});

final searchRepositoryProvider = Provider<ISearchRepository>((ref) {
  final searchService = ref.read(searchServiceProvider);
  return SearchRepositoryImpl(searchService);
});


// ──────────────────────────────────────────────────────────────────────────────
// FEATURE SERVICES
// Her servis buradan inject edilir. UI/notifier'lar doğrudan new() yapmaz.
// ──────────────────────────────────────────────────────────────────────────────

final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService();
});

final dailyTipServiceProvider = Provider<DailyTipService>((ref) {
  return DailyTipService();
});

final examServiceProvider = Provider<ExamService>((ref) {
  return ExamService();
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final mockExamServiceProvider = Provider<MockExamService>((ref) {
  return MockExamService();
});

final examResultServiceProvider = Provider<ExamResultService>((ref) {
  return ExamResultService();
});

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

final topicServiceProvider = Provider<TopicService>((ref) {
  return TopicService();
});

final trafficSignServiceProvider = Provider<TrafficSignService>((ref) {
  return TrafficSignService();
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService();
});

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService();
});

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

final workbookServiceProvider = Provider<WorkbookService>((ref) {
  return WorkbookService();
});

final packageServiceProvider = Provider<PackageService>((ref) {
  return PackageService();
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

final userRepositoryServiceProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
