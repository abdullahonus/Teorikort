import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/traffic_sign.dart';

class TrafficSignService extends BaseApiService {
  Future<ApiResponse<TrafficSignResponse>> getSigns({
    int page = 1,
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    final params = {
      'page': page.toString(),
      'language': language,
    };

    return await handleResponse<TrafficSignResponse>(
      get(
        ApiConstants.signs,
        queryParameters: params,
      ),
      TrafficSignResponse.fromJson,
    );
  }

  Future<ApiResponse<TrafficSign>> getSignById(
    String id, {
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    final params = {'language': language};

    return await handleResponse<TrafficSign>(
      get(
        ApiConstants.signDetail(id),
        queryParameters: params,
      ),
      TrafficSign.fromJson,
    );
  }
}
