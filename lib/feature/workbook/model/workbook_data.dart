import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class Workbook extends Equatable {
  final int id;
  final int userId;
  final int courseId;
  final String detail;
  final bool passed;
  final int time;
  final DateTime createdAt;

  const Workbook({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.detail,
    required this.passed,
    required this.time,
    required this.createdAt,
  });

  factory Workbook.fromJson(Map<String, dynamic> json) {
    return Workbook(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      courseId: json['course_id'] is int
          ? json['course_id']
          : int.tryParse(json['course_id']?.toString() ?? '0') ?? 0,
      detail: json['workhood_detail'] ?? '',
      passed: (json['passed'] == 1 || json['passed'] == true),
      time: json['time'] is int
          ? json['time']
          : int.tryParse(json['time']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userId, courseId, detail, passed, time, createdAt];
}

class WorkbookResponse extends Equatable {
  final List<Workbook> workbooks;
  final int currentPage;
  final int lastPage;

  const WorkbookResponse({
    required this.workbooks,
    required this.currentPage,
    required this.lastPage,
  });

  factory WorkbookResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] ?? {};
    return WorkbookResponse(
      workbooks: (json['data'] as List? ?? [])
          .map((item) => Workbook.fromJson(item))
          .toList(),
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [workbooks, currentPage, lastPage];
}
