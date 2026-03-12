class PaymentStatus {
  final String id;
  final String status;
  final String? errorMessage;

  PaymentStatus({
    required this.id,
    required this.status,
    this.errorMessage,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ERROR',
      errorMessage: json['errorMessage']?.toString(),
    );
  }

  bool get isPaid => status == 'PAID';
  bool get isCreated => status == 'CREATED';
  bool get isDeclined => status == 'DECLINED';
  bool get isError => status == 'ERROR';
}
