import 'package:driving_license_exam/core/services/json_service.dart';

class CategoryService {
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final json = await JsonService.getCategoriesData();
      return json['categories'] as Map<String, dynamic>;
    } catch (e) {
      print('Kategoriler yüklenirken hata oluştu: $e');
      throw Exception('Kategoriler yüklenemedi: $e');
    }
  }
}
