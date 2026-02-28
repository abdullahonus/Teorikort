import 'package:flutter/material.dart';
import '../../../../core/services/base_api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/api_response.dart';

class TrafficSign {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String imageUrl;

  TrafficSign({
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
}

class TrafficSignResponse {
  final List<TrafficSign> signs;
  final PaginationData pagination;

  TrafficSignResponse({required this.signs, required this.pagination});

  factory TrafficSignResponse.fromJson(Map<String, dynamic> json) {
    return TrafficSignResponse(
      signs: (json['data'] as List? ?? [])
          .map((e) => TrafficSign.fromJson(e))
          .toList(),
      pagination: PaginationData.fromJson(json['meta'] ?? {}),
    );
  }
}

class PaginationData {
  final int currentPage;
  final int lastPage;
  final int total;

  PaginationData({required this.currentPage, required this.lastPage, required this.total});

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }
}
