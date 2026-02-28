import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../models/package.dart';

class PackageService extends BaseApiService {
  // GET /packages
  Future<ApiResponse<List<Package>>> getPackages({
    BuildContext? context,
  }) async {
    return await handleListResponse<Package>(
      get(ApiConstants.packages),
      Package.fromJson,
    );
  }

  // GET /packages/{id}
  Future<ApiResponse<Package>> getPackageById(
    String id, {
    BuildContext? context,
  }) async {
    return await handleResponse<Package>(
      get(ApiConstants.packageDetail(id)),
      Package.fromJson,
    );
  }
}
