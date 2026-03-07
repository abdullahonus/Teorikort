import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/provider/service_providers.dart';
import '../model/exam_category.dart';

final practiceSubCategoriesProvider =
    FutureProvider.family<List<ExamCategory>, String>((ref, categoryId) async {
  final repository = ref.read(examRepositoryProvider);
  final response = await repository.getSubCategories(categoryId);
  if (response.success && response.data != null) {
    return response.data!;
  }
  throw Exception(response.message ?? 'Failed to load subcategories');
});

final practiceTestsProvider = FutureProvider.family<List<ExamCategory>, String>(
    (ref, subcategoryId) async {
  final repository = ref.read(examRepositoryProvider);
  final response = await repository.getTests(subcategoryId);
  if (response.success && response.data != null) {
    return response.data!;
  }
  throw Exception(response.message ?? 'Failed to load tests');
});
