import 'dart:io';

import 'package:taxi/product/manager/network/network_manager.dart';

abstract class IQuizService extends INetworkManager {
  Future<Map<String, dynamic>?> getQuiz();
}

class QuizService extends IQuizService {
  @override
  Future<Map<String, dynamic>?> getQuiz() async {
    try {
      final response = await dio.get("", queryParameters: {
        'amount': 10,
      });
      if (response.statusCode == HttpStatus.ok) {
        print(response.data);
        return response.data;
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }
}
