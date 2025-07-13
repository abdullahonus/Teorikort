import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/exam_data.dart';

class ExamService extends BaseApiService {
  // Get exam data from API
  Future<ApiResponse<ExamData>> getExamData({
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      return await handleResponse<ExamData>(
        get(
          ApiConstants.examCategories,
          language: language,
        ),
        ExamData.fromJson,
      );
    } catch (e) {
      return ApiResponse<ExamData>(
        success: false,
        statusCode: 500,
        message: 'Sınav verileri yüklenemedi: $e',
      );
    }
  }

  // Get exam categories
  Future<ApiResponse<List<ExamCategory>>> getExamCategories({
    BuildContext? context,
  }) async {
    try {
      final language = getCurrentLanguage(context);

      return await handleListResponse<ExamCategory>(
        get(
          ApiConstants.examCategories,
          language: language,
        ),
        ExamCategory.fromJson,
      );
    } catch (e) {
      return ApiResponse<List<ExamCategory>>(
        success: false,
        statusCode: 500,
        message: 'Sınav kategorileri yüklenemedi: $e',
      );
    }
  }
}
