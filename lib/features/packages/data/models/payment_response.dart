class PaymentResponse {
  final String paymentId;
  final String token;

  PaymentResponse({
    required this.paymentId,
    required this.token,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['payment_id']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }
}
