class Package {
  final int id;
  final int appId;
  final String appName;
  final String name;
  final int durationMonth;
  final double price;
  final bool canPurchase;
  final bool isActive;
  final String? statusText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Package({
    required this.id,
    required this.appId,
    required this.appName,
    required this.name,
    required this.durationMonth,
    required this.price,
    required this.canPurchase,
    required this.isActive,
    this.statusText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? 0,
      appId: json['app_id'] ?? 0,
      appName: json['app_name'] ?? '',
      name: json['name'] ?? '',
      durationMonth: json['duration_month'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      canPurchase: json['can_purchase'] ?? false,
      isActive: json['is_active'] ?? false,
      statusText: json['status_text'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'app_name': appName,
      'name': name,
      'duration_month': durationMonth,
      'price': price,
      'can_purchase': canPurchase,
      'is_active': isActive,
      'status_text': statusText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
