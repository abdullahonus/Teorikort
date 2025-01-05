import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyTip {
  final int id;
  final String title;
  final String content;
  final String category;
  final String icon;

  DailyTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.icon,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
    );
  }
}

class DailyTipService {
  static final DailyTipService _instance = DailyTipService._internal();
  factory DailyTipService() => _instance;

  DailyTipService._internal();

  static const String _lastTipDateKey = 'last_tip_date';
  static const String _lastTipIdKey = 'last_tip_id';

  Future<DailyTip> getDailyTip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTipDate = prefs.getString(_lastTipDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Eğer bugün için ipucu gösterilmemişse yeni bir ipucu seç
      if (lastTipDate != today) {
        final String jsonString =
            await rootBundle.loadString('assets/data/daily_tips.json');
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        final tips = (jsonData['tips'] as List)
            .map((tip) => DailyTip.fromJson(tip))
            .toList();

        // Son gösterilen ipucu ID'sini al
        final lastTipId = prefs.getInt(_lastTipIdKey) ?? 0;

        // Sıradaki ipucunu seç (son ipucuna geldiysek başa dön)
        final nextTipId = (lastTipId % tips.length) + 1;
        final todaysTip = tips.firstWhere((tip) => tip.id == nextTipId);

        // Yeni ipucu bilgilerini kaydet
        await prefs.setString(_lastTipDateKey, today);
        await prefs.setInt(_lastTipIdKey, nextTipId);

        return todaysTip;
      } else {
        // Bugünün ipucunu göster
        final String jsonString =
            await rootBundle.loadString('assets/data/daily_tips.json');
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        final tips = (jsonData['tips'] as List)
            .map((tip) => DailyTip.fromJson(tip))
            .toList();
        final currentTipId = prefs.getInt(_lastTipIdKey) ?? 1;
        return tips.firstWhere((tip) => tip.id == currentTipId);
      }
    } catch (e) {
      print('Error loading daily tip: $e');
      // Hata durumunda varsayılan bir ipucu döndür
      return DailyTip(
        id: 1,
        title: 'Güvenli Sürüş',
        content: 'Her zaman trafik kurallarına uyun ve güvenli sürüş yapın.',
        category: 'safety',
        icon: 'safety',
      );
    }
  }
}
