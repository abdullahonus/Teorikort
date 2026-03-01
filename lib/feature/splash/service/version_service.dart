import '../../../core/services/base_api_service.dart';
import '../../../core/models/api_response.dart';
import '../../../data/splash_response_model.dart';

class VersionService extends BaseApiService {
  Future<ApiResponse<SplashResponseModel>> getSplashData() async {
    // Simüle edilen gecikme
    await Future.delayed(const Duration(seconds: 1));

    // Backend hazır olmadığında mock veri dönüyoruz
    final mockJson = _mockSplashResponse();
    final data = mockJson['data'] as Map<String, dynamic>;

    return ApiResponse<SplashResponseModel>(
      success: true,
      statusCode: 200,
      data: SplashResponseModel.fromJson(data),
    );
  }

  dynamic _mockSplashResponse() {
    return {
      "status": 200,
      "description": "Splash configuration data",
      "data": {
        "version": {
          "ios": "1.0.5",
          "android": "1.0.2",
          "force_update": false,
          "update_url":
              "https://play.google.com/store/apps/details?id=com.teorikort",
          "title": "Yeni Güncelleme Mevcut!",
          "description":
              "Uygulamanın performansını artırmak için yeni sürümü yüklemenizi öneririz."
        },
        "maintenance": {
          "status": false,
          "title": "Bakım Çalışması",
          "description":
              "Şu anda sistemlerimizi güncelliyoruz. Lütfen 2 saat sonra tekrar deneyiniz.",
          "end_time": "2024-03-15T15:00:00Z"
        },
        "languages": [
          {
            "code": "tr",
            "name": "Türkçe",
            "flag": "tr_flag_url",
            "is_default": true
          },
          {
            "code": "en",
            "name": "English",
            "flag": "en_flag_url",
            "is_default": false
          }
        ],
        "device_key": "unique_secure_device_key_from_server"
      }
    };
  }
}
