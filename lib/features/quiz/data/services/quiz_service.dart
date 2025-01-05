import 'package:driving_license_exam/core/services/json_service.dart';
import '../models/quiz_data.dart';

class QuizService {
  // Geçerli kategorileri tanımlayalım
  static const validCategories = {
    'traffic_signs',
    'traffic_rules',
    'first_aid',
    'vehicle_tech'
  };

  Future<List<QuizQuestion>> loadQuizQuestions(String category) async {
    try {
      // Kategori kontrolü yapalım
      if (!validCategories.contains(category)) {
        throw Exception(
            'Geçersiz kategori: $category\nGeçerli kategoriler: ${validCategories.join(", ")}');
      }

      final json = await JsonService.getQuestionsData();

      // Debug için JSON çıktısını görelim
      print('Loaded JSON: $json');

      final questions = json['questions'];
      if (questions == null) {
        throw Exception('JSON verisinde "questions" alanı bulunamadı');
      }

      final categoryQuestions = questions[category];
      if (categoryQuestions == null) {
        throw Exception('$category kategorisi için soru bulunamadı');
      }

      if (categoryQuestions is! List) {
        throw Exception('Kategori soruları liste formatında değil');
      }

      return categoryQuestions.map((q) {
        if (q == null) {
          throw Exception('Soru verisi null');
        }
        return QuizQuestion.fromJson(q as Map<String, dynamic>);
      }).toList();
    } catch (e, stackTrace) {
      print('Sorular yüklenirken detaylı hata: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Sorular yüklenemedi: $e');
    }
  }

  Future<QuizData> getQuizData() async {
    try {
      final json = await JsonService.getQuestionsData();
      return QuizData.fromJson(json);
    } catch (e) {
      print('Quiz verisi yüklenirken hata oluştu: $e');
      throw Exception('Quiz verisi yüklenemedi: $e');
    }
  }
}
