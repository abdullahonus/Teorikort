import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/search_response.dart';

class SearchService extends BaseApiService {
  // GET /search/questions?q={query}&page={page}
  Future<ApiResponse<SearchResponseData>> searchQuestions(
    String query, {
    int page = 1,
    BuildContext? context,
  }) async {
    final language = getCurrentLanguage(context);
    final params = {
      'q': query,
      'page': page.toString(),
      'language': language,
    };

    return await handleResponse<SearchResponseData>(
      get(
        ApiConstants.searchQuestions,
        queryParameters: params,
      ),
      SearchResponseData.fromJson,
    );
  }
}
