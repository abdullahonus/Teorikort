import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class MockExamService {
  static final MockExamService _instance = MockExamService._internal();
  factory MockExamService() => _instance;

  MockExamService._internal();

  Future<List<Map<String, dynamic>>> getQuestionsByDifficulty(
      String difficulty) async {
    try {
      // JSON dosyasını oku
      final String jsonString =
          await rootBundle.loadString('assets/data/mock_exam_questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Seçilen zorluk seviyesindeki soruları al
      final questions =
          List<Map<String, dynamic>>.from(jsonData[difficulty]['questions']);

      // Soruları karıştır
      questions.shuffle();

      return questions;
    } catch (e) {
      print('Error loading questions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRandomQuestions(
      {int count = 10}) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/mock_exam_questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Tüm zorluk seviyelerinden soruları al
      List<Map<String, dynamic>> allQuestions = [];

      for (var difficulty in ['easy', 'medium', 'hard']) {
        final questions =
            List<Map<String, dynamic>>.from(jsonData[difficulty]['questions']);
        allQuestions.addAll(questions);
      }

      // Soruları karıştır
      allQuestions.shuffle();

      // İstenen sayıda soru döndür (eğer toplam soru sayısı istenen sayıdan azsa tüm soruları döndür)
      return allQuestions.take(min(count, allQuestions.length)).toList();
    } catch (e) {
      print('Error loading random questions: $e');
      return [];
    }
  }

  // Soruyu doğru formata dönüştür
  Map<String, dynamic> formatQuestion(Map<String, dynamic> question) {
    return {
      'id': question['id'],
      'question': question['question'],
      'image_url': question['image_url'],
      'options': question['options'],
      'correct_answer': question['correct_answer'],
      'explanation': question['explanation'],
    };
  }
}
