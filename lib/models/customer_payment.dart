class CustomerPayment {
  final String id;
  final String customerId;
  final String customerName;
  final double amount; // مثبت: دریافتی از مشتری، منفی: بدهی دستی/پرداخت ما به مشتری
  final String date;
  final String? time;
  final String paymentMethod; // card, bank_transfer, cash, check
  final String? type; // payment, payout
  final String? referenceNumber;
  final String? description;
  final int createdAt;

  CustomerPayment({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.date,
    this.time,
    this.paymentMethod = 'card',
    this.type = 'payment',
    this.referenceNumber,
    this.description,
    required this.createdAt,
  });

  factory CustomerPayment.fromJson(Map<String, dynamic> json) {
    return CustomerPayment(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'card',
      type: json['type']?.toString() ?? 'payment',
      referenceNumber: json['referenceNumber']?.toString(),
      description: json['description']?.toString(),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'date': date,
      if (time != null) 'time': time,
      'paymentMethod': paymentMethod,
      if (type != null) 'type': type,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (description != null) 'description': description,
      'createdAt': createdAt,
    };
  }
}
