import 'dart:convert';
import 'package:flutter/services.dart';
import '../constants/app_strings.dart';

class StringsService {
  static Future<Map<String, dynamic>> getStatisticsStrings() async {
    final String response =
        await rootBundle.loadString(AppStrings.statisticsDataPath);
    return json.decode(response);
  }
}
