import '../../../core/models/api_response.dart';
import '../../../core/services/logger_service.dart';
import '../../../domain/repository/i_workbook_repository.dart';
import '../../../feature/workbook/model/workbook_data.dart' as model;
import '../../../features/workbook/data/services/workbook_service.dart';

class WorkbookRepositoryImpl implements IWorkbookRepository {
  final WorkbookService _service;

  WorkbookRepositoryImpl(this._service);

  @override
  Future<ApiResponse<model.WorkbookResponse>> getWorkbooks({int page = 1}) async {
    try {
      final response = await _service.getWorkbooks(page: page);
      if (response.success && response.data != null) {
        final legacyRes = response.data!;
        return ApiResponse.success(model.WorkbookResponse(
          workbooks: legacyRes.workbooks.map((w) => model.Workbook(
            id: w.id,
            userId: w.userId,
            courseId: w.courseId,
            detail: w.detail,
            passed: w.passed,
            time: w.time,
            createdAt: w.createdAt,
          )).toList(),
          currentPage: legacyRes.pagination.currentPage,
          lastPage: legacyRes.pagination.lastPage,
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('WorkbookRepositoryImpl.getWorkbooks', e);
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<model.Workbook>> saveProgress({
    required int courseId,
    required String detail,
    required bool passed,
    required int timeSeconds,
  }) async {
    try {
      final response = await _service.saveWorkbook(
        courseId: courseId,
        detail: detail,
        passed: passed,
        time: timeSeconds,
      );
      if (response.success && response.data != null) {
        final w = response.data!;
        return ApiResponse.success(model.Workbook(
          id: w.id,
          userId: w.userId,
          courseId: w.courseId,
          detail: w.detail,
          passed: w.passed,
          time: w.time,
          createdAt: w.createdAt,
        ));
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      LoggerService.error('WorkbookRepositoryImpl.saveProgress', e);
      return ApiResponse.error(e.toString());
    }
  }
}
