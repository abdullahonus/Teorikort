import 'package:driving_license_exam/core/services/json_service.dart';
import '../models/home_data.dart';

class HomeService {
  Future<HomeData> getHomeData() async {
    final json = await JsonService.getHomeData();
    return HomeData.fromJson(json);
  }
}
