import 'package:equatable/equatable.dart';

/// Spec: STATE MODEL PATTERN — Equatable + copyWith
/// Yeni API yapısına göre güncellendi:
/// data.signs[] → kategori listesi (üst başlıklar, top=0)
///   └─ children[] → gerçek trafik işaretleri (top=parentId)
class TrafficSign extends Equatable {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String imageUrl;
  final int top; // parent id (0 = kategori/üst başlık)
  final List<TrafficSign> children;

  const TrafficSign({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    required this.imageUrl,
    required this.top,
    this.children = const [],
  });

  /// Üst başlık (kategori) mı?
  bool get isCategory => top == 0;

  /// Gerçek trafik işareti mi?
  bool get isLeaf => top != 0 && children.isEmpty;

  /// Açıklama metni (null-safe)
  String get descriptionText => description ?? '';

  factory TrafficSign.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List<dynamic>? ?? [];
    return TrafficSign(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: (json['img'] ?? json['image_url'] ?? '') as String,
      top: json['top'] as int? ?? 0,
      children: childrenJson
          .map((e) => TrafficSign.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  TrafficSign copyWith({
    int? id,
    String? title,
    String? slug,
    String? description,
    String? imageUrl,
    int? top,
    List<TrafficSign>? children,
  }) {
    return TrafficSign(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      top: top ?? this.top,
      children: children ?? this.children,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, slug, description, imageUrl, top, children];
}

/// Üst seviye API response: data => { signs: [...], pagination: {...} }
class TrafficSignResponse extends Equatable {
  /// Her eleman bir kategori (top=0), içinde children ile gerçek işaretler
  final List<TrafficSign> signs;
  final PaginationData pagination;

  const TrafficSignResponse({
    required this.signs,
    required this.pagination,
  });

  factory TrafficSignResponse.fromJson(Map<String, dynamic> json) {
    return TrafficSignResponse(
      signs: (json['signs'] as List? ?? [])
          .map((e) => TrafficSign.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationData.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Tüm çocukları (gerçek işaretleri) düz liste olarak döndürür
  List<TrafficSign> get allLeafSigns =>
      signs.expand((cat) => cat.children).toList();

  @override
  List<Object?> get props => [signs, pagination];
}

class PaginationData extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationData({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}
