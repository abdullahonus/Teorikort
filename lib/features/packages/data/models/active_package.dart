class ActivePackage {
  final int id;
  final int catId;
  final int status;
  final String statusText;
  final int limitUse;
  final int used;
  final int remainingUse;
  final DateTime expiresAt;
  final double remainingDays;
  final int remainingHours;
  final bool expired;

  ActivePackage({
    required this.id,
    required this.catId,
    required this.status,
    required this.statusText,
    required this.limitUse,
    required this.used,
    required this.remainingUse,
    required this.expiresAt,
    required this.remainingDays,
    required this.remainingHours,
    required this.expired,
  });

  factory ActivePackage.fromJson(Map<String, dynamic> json) {
    final remainingTime = json['remaining_time'] as Map<String, dynamic>? ?? {};

    return ActivePackage(
      id: json['id'] ?? 0,
      catId: json['cat_id'] ?? 0,
      status: json['status'] ?? 0,
      statusText: json['status_text'] ?? '',
      limitUse: json['limit_use'] ?? 0,
      used: json['used'] ?? 0,
      remainingUse: json['remaining_use'] ?? 0,
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now(),
      remainingDays: (remainingTime['days'] ?? 0).toDouble(),
      remainingHours: remainingTime['hours'] ?? 0,
      expired: remainingTime['expired'] ?? false,
    );
  }
}
