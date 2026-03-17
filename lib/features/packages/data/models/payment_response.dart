class PaymentResponse {
  final String paymentReference;
  final String? callbackIdentifier;

  PaymentResponse({
    required this.paymentReference,
    this.callbackIdentifier,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    // Handle double nested data structure from API: data -> data -> payeePaymentReference
    Map<String, dynamic> targetData = json;
    
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      targetData = json['data'] as Map<String, dynamic>;
      if (targetData.containsKey('data') && targetData['data'] is Map<String, dynamic>) {
        targetData = targetData['data'] as Map<String, dynamic>;
      }
    }
    
    return PaymentResponse(
      paymentReference: targetData['payeePaymentReference']?.toString() ?? '',
      callbackIdentifier: targetData['callbackIdentifier']?.toString(),
    );
  }
}
