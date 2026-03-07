import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/workbook_data.dart';

class WorkbookService extends BaseApiService {
  // GET /workbooks
  Future<ApiResponse<WorkbookResponse>> getWorkbooks({
    int page = 1,
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    final params = {
      'page': page.toString(),
      'language': language,
    };

    return await handleResponse<WorkbookResponse>(
      get(
        ApiConstants.workbooks,
        queryParameters: params,
      ),
      WorkbookResponse.fromJson,
    );
  }

  // POST /workbooks
  Future<ApiResponse<Workbook>> saveWorkbook({
    required int courseId,
    required String detail,
    required bool passed,
    required int time,
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    final data = {
      'course_id': courseId,
      'workhood_detail': detail,
      'passed': passed ? 1 : 0,
      'time': time,
      'language': language,
    };

    return await handleResponse<Workbook>(
      post(
        ApiConstants.workbooks,
        data: data,
      ),
      Workbook.fromJson,
    );
  }
}
