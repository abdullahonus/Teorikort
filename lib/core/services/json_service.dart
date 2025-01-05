import 'dart:convert';
import 'package:flutter/services.dart';

class JsonService {
  static Future<Map<String, dynamic>> loadJson(String path) async {
    final jsonString = await rootBundle.loadString('assets/data/$path');
    return json.decode(jsonString);
  }

  static Future<Map<String, dynamic>> getHomeData() async {
    return await loadJson('home_data.json');
  }

  static Future<Map<String, dynamic>> getExamsData() async {
    return await loadJson('exams_data.json');
  }

  static Future<Map<String, dynamic>> getQuestionsData() async {
    return await loadJson('questions_data.json');
  }

  static Future<Map<String, dynamic>> getStatisticsData() async {
    return await loadJson('statistics_data.json');
  }

  static Future<Map<String, dynamic>> getProfileData() async {
    return await loadJson('profile_data.json');
  }

  static Future<Map<String, dynamic>> getCategoriesData() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/categories_data.json');
    return json.decode(jsonString);
  }
}
