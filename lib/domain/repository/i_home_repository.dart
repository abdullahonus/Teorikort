import '../../../features/home/data/services/home_service.dart';
import '../../../features/home/data/services/daily_tip_service.dart';
import '../../../core/models/api_response.dart';

/// Home işlemleri için soyut kontrat.
abstract class IHomeRepository {
  Future<ApiResponse<HomeData>> getHomeData({String? language});
  Future<DailyTip?> getDailyTip({String? language});
}
