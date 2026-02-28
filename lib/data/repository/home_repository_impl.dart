import '../../core/models/api_response.dart';
import '../../core/services/logger_service.dart';
import '../../domain/repository/i_home_repository.dart';
import '../../features/home/data/services/home_service.dart';
import '../../features/home/data/services/daily_tip_service.dart';

/// IHomeRepository'nin somut implementasyonu.
/// HomeService + DailyTipService inject alır — doğrudan new() yapmaz.
class HomeRepositoryImpl implements IHomeRepository {
  final HomeService _homeService;
  final DailyTipService _dailyTipService;

  HomeRepositoryImpl(this._homeService, this._dailyTipService);

  @override
  Future<ApiResponse<HomeData>> getHomeData({String? language}) async {
    try {
      return await _homeService.getHomeData();
    } catch (e) {
      LoggerService.error('HomeRepository.getHomeData', e);
      return ApiResponse<HomeData>(
        success: false,
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  @override
  Future<DailyTip?> getDailyTip({String? language}) async {
    try {
      return await _dailyTipService.getDailyTip();
    } catch (e) {
      LoggerService.error('HomeRepository.getDailyTip', e);
      return null;
    }
  }
}
