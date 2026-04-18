class PaymentModel {
  final int? paymentId;
  final int userId;
  final String paymentMethod; // 'mpesa' or 'card'
  final double amount;
  final String
  transactionReference; // M-Pesa CheckoutRequestID or Card Trans ID
  final String status;
  final String? phoneNumber;
  final String? cardLastFour;

  PaymentModel({
    this.paymentId,
    required this.userId,
    required this.paymentMethod,
    required this.amount,
    required this.transactionReference,
    required this.status,
    this.phoneNumber,
    this.cardLastFour,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id'] != null
          ? int.tryParse(json['payment_id'].toString())
          : null,
      userId: int.parse(json['user_id'].toString()),
      paymentMethod: json['payment_method'] as String,
      amount: double.parse(json['amount'].toString()),
      transactionReference: json['transaction_reference'] as String,
      status: json['status'] as String,
      phoneNumber: json['phone_number'] as String?,
      cardLastFour: json['card_last_four'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'payment_method': paymentMethod,
      'amount': amount,
      'transaction_reference': transactionReference,
      'status': status,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (cardLastFour != null) 'card_last_four': cardLastFour,
    };
  }
}
