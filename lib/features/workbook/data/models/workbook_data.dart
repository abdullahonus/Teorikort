import '../../../topics/data/models/topic.dart';

class WorkbookResponse {
  final List<Workbook> workbooks;
  final WorkbookPagination pagination;

  WorkbookResponse({
    required this.workbooks,
    required this.pagination,
  });

  factory WorkbookResponse.fromJson(Map<String, dynamic> json) {
    return WorkbookResponse(
      workbooks: (json['workbooks'] as List? ?? [])
          .map((w) => Workbook.fromJson(w))
          .toList(),
      pagination: WorkbookPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Workbook {
  final int id;
  final int userId;
  final int courseId;
  final Topic course;
  final String detail;
  final bool passed;
  final int time;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workbook({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.course,
    required this.detail,
    required this.passed,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Workbook.fromJson(Map<String, dynamic> json) {
    return Workbook(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      course: Topic.fromJson(json['course'] ?? {}),
      detail: json['workhood_detail'] ?? '',
      passed: (json['passed'] ?? 0) == 1,
      time: json['time'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class WorkbookPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  WorkbookPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory WorkbookPagination.fromJson(Map<String, dynamic> json) {
    return WorkbookPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
