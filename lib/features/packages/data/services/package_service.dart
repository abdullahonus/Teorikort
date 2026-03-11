import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/services/base_api_service.dart';
import '../models/active_package.dart';
import '../models/package.dart';
import '../models/payment_response.dart';

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

  // POST /swish/create
  Future<ApiResponse<PaymentResponse>> createPayment(int packageId) async {
    return await handleResponse<PaymentResponse>(
      post(
        ApiConstants.swishCreate,
        data: {'package_id': packageId},
      ),
      PaymentResponse.fromJson,
    );
  }

  // GET /subscription/active-package
  Future<ApiResponse<ActivePackage>> getActivePackage({
    BuildContext? context,
  }) async {
    return await handleResponse<ActivePackage>(
      get(ApiConstants.activePackage),
      ActivePackage.fromJson,
    );
  }
}
