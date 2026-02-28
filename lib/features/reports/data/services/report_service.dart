import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';

class ReportService extends BaseApiService {
  Future<ApiResponse<dynamic>> reportQuestion({
    required String questionId,
    required String description,
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    final data = {
      'question_id': questionId,
      'description': description,
      'language': language,
    };

    return await handleResponse<dynamic>(
      post(
        ApiConstants.reports,
        data: data,
      ),
      (json) => json,
    );
  }
}
