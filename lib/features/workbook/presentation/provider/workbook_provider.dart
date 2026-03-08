import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/workbook_data.dart';
import '../../data/services/workbook_service.dart';

final workbookServiceProvider = Provider((ref) => WorkbookService());

final workbookListProvider =
    StateNotifierProvider<WorkbookListNotifier, WorkbookListState>((ref) {
  return WorkbookListNotifier(ref.watch(workbookServiceProvider));
});

class WorkbookListState {
  final List<Workbook> workbooks;
  final bool isLoading;
  final String? error;

  WorkbookListState({
    this.workbooks = const [],
    this.isLoading = false,
    this.error,
  });

  WorkbookListState copyWith({
    List<Workbook>? workbooks,
    bool? isLoading,
    String? error,
  }) {
    return WorkbookListState(
      workbooks: workbooks ?? this.workbooks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class WorkbookListNotifier extends StateNotifier<WorkbookListState> {
  final WorkbookService _service;

  WorkbookListNotifier(this._service) : super(WorkbookListState());

  Future<void> fetchWorkbooks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getWorkbooks();
      if (response.success) {
        state = state.copyWith(
          workbooks: response.data?.workbooks ?? [],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Veriler yüklenemedi',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> deleteWorkbook(int id) async {
    try {
      final response = await _service.deleteWorkbook(workbookId: id);
      if (response.success) {
        state = state.copyWith(
          workbooks: state.workbooks.where((w) => w.id != id).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
