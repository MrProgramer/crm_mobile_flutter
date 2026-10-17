class TreasuryTransaction {
  final String id;
  final String type; // expense, transfer, deposit
  final String source; // cash, bank, personal
  final String? destination; // bank, cash (for transfer)
  final double amount;
  final String date;
  final String time;
  final String description;
  final String category; // rent, bills, salary, logistics, etc.
  final String? referenceCode;
  final String? receiptNumber;
  final String? impactOnLiquidity; // deduct, none, inject
  final int createdAt;

  TreasuryTransaction({
    required this.id,
    required this.type,
    required this.source,
    this.destination,
    required this.amount,
    required this.date,
    required this.time,
    required this.description,
    required this.category,
    this.referenceCode,
    this.receiptNumber,
    this.impactOnLiquidity = 'deduct',
    required this.createdAt,
  });

  factory TreasuryTransaction.fromJson(Map<String, dynamic> json) {
    return TreasuryTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'expense',
      source: json['source']?.toString() ?? 'cash',
      destination: json['destination']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'متفرقه',
      referenceCode: json['referenceCode']?.toString(),
      receiptNumber: json['receiptNumber']?.toString(),
      impactOnLiquidity: json['impactOnLiquidity']?.toString() ?? 'deduct',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'source': source,
      if (destination != null) 'destination': destination,
      'amount': amount,
      'date': date,
      'time': time,
      'description': description,
      'category': category,
      if (referenceCode != null) 'referenceCode': referenceCode,
      if (receiptNumber != null) 'receiptNumber': receiptNumber,
      'impactOnLiquidity': impactOnLiquidity,
      'createdAt': createdAt,
    };
  }
}
