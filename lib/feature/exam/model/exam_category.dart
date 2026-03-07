import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatabl + copyWith
class ExamCategory extends Equatable {
  final int id;
  final String title;
  final String description;
  final int timeSeconds;
  final int successPoint;
  final String imageUrl;
  final int totalQuestions;

  const ExamCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.timeSeconds,
    required this.successPoint,
    required this.imageUrl,
    required this.totalQuestions,
  });

  factory ExamCategory.fromJson(Map<String, dynamic> json) {
    // API provides 'image' or 'icon' sometimes, handling both
    // Also handling nested categories from 'category' key
    final data = json.containsKey('category')
        ? json['category'] as Map<String, dynamic>
        : json;

    return ExamCategory(
      id: data['id'] is int
          ? data['id']
          : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
      title: _parseField(data['title']),
      description: _parseField(data['description']),
      timeSeconds: data['time_secound'] ?? 2700,
      successPoint: data['success_pint'] ?? 70,
      imageUrl: data['image'] ?? data['icon'] ?? '',
      totalQuestions: data['total_questions'] ?? 45,
    );
  }

  factory ExamCategory.fromLegacy(dynamic legacy) {
    if (legacy is Map<String, dynamic>) return ExamCategory.fromJson(legacy);
    return ExamCategory.fromJson(legacy.toJson());
  }

  static String _parseField(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field['tr']?.toString() ??
          field['en']?.toString() ??
          (field.values.isNotEmpty ? field.values.first?.toString() ?? '' : '');
    }
    return field?.toString() ?? '';
  }

  ExamCategory copyWith({
    int? id,
    String? title,
    String? description,
    int? timeSeconds,
    int? successPoint,
    String? imageUrl,
    int? totalQuestions,
  }) =>
      ExamCategory(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        timeSeconds: timeSeconds ?? this.timeSeconds,
        successPoint: successPoint ?? this.successPoint,
        imageUrl: imageUrl ?? this.imageUrl,
        totalQuestions: totalQuestions ?? this.totalQuestions,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        timeSeconds,
        successPoint,
        imageUrl,
        totalQuestions
      ];
}
