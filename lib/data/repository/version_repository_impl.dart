import '../../core/models/api_response.dart';
import '../splash_response_model.dart';
import '../../feature/splash/service/version_service.dart';
import '../../domain/repository/version_repository.dart';

class VersionRepositoryImpl implements IVersionRepository {
  final VersionService _service;

  VersionRepositoryImpl(this._service);

  @override
  Future<ApiResponse<SplashResponseModel>> getAppVersion() async {
    return await _service.getSplashData();
  }
}
