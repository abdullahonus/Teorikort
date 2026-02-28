import 'package:teorikort/core/models/api_response.dart';
import 'package:teorikort/feature/workbook/model/workbook_data.dart';

abstract class IWorkbookRepository {
  /// Fetches paginated list of workbooks (study history).
  Future<ApiResponse<WorkbookResponse>> getWorkbooks({int page = 1});

  /// Saves study session progress.
  Future<ApiResponse<Workbook>> saveProgress({
    required int courseId,
    required String detail,
    required bool passed,
    required int timeSeconds,
  });
}
