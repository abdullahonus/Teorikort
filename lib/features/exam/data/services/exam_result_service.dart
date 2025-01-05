import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_result.dart';

class ExamResultService {
  static const String _key = 'exam_results';

  Future<void> saveExamResult(ExamResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await getExamResults();
    results.add(result);

    await prefs.setString(
        _key,
        jsonEncode(
          results.map((r) => r.toJson()).toList(),
        ));
  }

  Future<List<ExamResult>> getExamResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getString(_key);
    if (resultsJson == null) return [];

    final List<dynamic> resultsList = jsonDecode(resultsJson);
    return resultsList.map((json) => ExamResult.fromJson(json)).toList();
  }

  Future<List<ExamResult>> getExamResultsByCategory(String category) async {
    final results = await getExamResults();
    return results.where((result) => result.category == category).toList();
  }
}
