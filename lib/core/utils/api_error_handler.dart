import 'package:flutter/material.dart';
import '../models/api_response.dart';
import '../localization/app_localization.dart';

class ApiErrorHandler {
  // Show error message to user
  static void showError(
    BuildContext context,
    ApiResponse response, {
    String? customMessage,
  }) {
    final message = customMessage ?? response.message ?? 'Bir hata oluştu';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppLocalization.of(context).translate('common.close'),
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              message ??
                  AppLocalization.of(context).translate('common.loading'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText ??
                  AppLocalization.of(context).translate('common.cancel'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText ??
                  AppLocalization.of(context).translate('common.confirm'),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Handle API response and show appropriate UI feedback
  static Future<T?> handleApiCall<T>(
    BuildContext context,
    Future<ApiResponse<T>> apiCall, {
    String? loadingMessage,
    String? successMessage,
    bool showLoading = true,
    bool showSuccess = false,
  }) async {
    if (showLoading) {
      ApiErrorHandler.showLoading(context, message: loadingMessage);
    }

    try {
      final response = await apiCall;

      if (showLoading) {
        ApiErrorHandler.hideLoading(context);
      }

      if (response.success && response.data != null) {
        if (showSuccess && successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return response.data;
      } else {
        ApiErrorHandler.showError(context, response);
        return null;
      }
    } catch (e) {
      if (showLoading) {
        ApiErrorHandler.hideLoading(context);
      }

      ApiErrorHandler.showError(
        context,
        ApiResponse<T>(
          success: false,
          statusCode: 500,
          message: 'Beklenmeyen bir hata oluştu',
        ),
      );
      return null;
    }
  }

  // Get user-friendly error message based on status code
  static String getErrorMessage(BuildContext context, int statusCode) {
    switch (statusCode) {
      case 400:
        return AppLocalization.of(context).translate('errors.bad_request');
      case 401:
        return AppLocalization.of(context).translate('errors.unauthorized');
      case 403:
        return AppLocalization.of(context).translate('errors.forbidden');
      case 404:
        return AppLocalization.of(context).translate('errors.not_found');
      case 409:
        return AppLocalization.of(context).translate('errors.conflict');
      case 422:
        return AppLocalization.of(context).translate('errors.validation_error');
      case 429:
        return AppLocalization.of(context)
            .translate('errors.too_many_requests');
      case 500:
        return AppLocalization.of(context).translate('errors.server_error');
      case 503:
        return AppLocalization.of(context)
            .translate('errors.service_unavailable');
      default:
        return AppLocalization.of(context).translate('errors.unknown_error');
    }
  }
}
