import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
class TrafficSign extends Equatable {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String imageUrl;

  const TrafficSign({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.imageUrl,
  });

  factory TrafficSign.fromJson(Map<String, dynamic> json) {
    return TrafficSign(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  TrafficSign copyWith({
    int? id,
    String? title,
    String? slug,
    String? description,
    String? imageUrl,
  }) {
    return TrafficSign(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, title, slug, description, imageUrl];
}

class TrafficSignResponse extends Equatable {
  final List<TrafficSign> signs;
  final PaginationData pagination;

  const TrafficSignResponse({required this.signs, required this.pagination});

  factory TrafficSignResponse.fromJson(Map<String, dynamic> json) {
    return TrafficSignResponse(
      signs: (json['data'] as List? ?? [])
          .map((e) => TrafficSign.fromJson(e))
          .toList(),
      pagination: PaginationData.fromJson(json['meta'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [signs, pagination];
}

class PaginationData extends Equatable {
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginationData({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentPage, lastPage, total];
}
