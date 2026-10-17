import 'customer_payment.dart';

class Customer {
  final String id;
  final String name;
  final String? company;
  final String? customerType; // regular, distributor, supplier, both, partner
  final String phone;
  final String city;
  final String? address;
  final String? nationalCode;
  final double initialBalance; // مانده اولیه: مثبت بدهکار، منفی بستانکار
  final double? creditLimit; // سقف اعتبار خرید
  final String? notes;
  final int createdAt;
  final List<CustomerPayment>? payments;

  Customer({
    required this.id,
    required this.name,
    this.company,
    this.customerType = 'regular',
    required this.phone,
    required this.city,
    this.address,
    this.nationalCode,
    this.initialBalance = 0.0,
    this.creditLimit,
    this.notes,
    required this.createdAt,
    this.payments,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    var rawPayments = json['payments'] as List<dynamic>?;
    List<CustomerPayment>? parsedPayments = rawPayments
        ?.map((p) => CustomerPayment.fromJson(p as Map<String, dynamic>))
        .toList();

    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString(),
      customerType: json['customerType']?.toString() ?? 'regular',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString(),
      nationalCode: json['nationalCode']?.toString(),
      initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      payments: parsedPayments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (company != null) 'company': company,
      'customerType': customerType,
      'phone': phone,
      'city': city,
      if (address != null) 'address': address,
      if (nationalCode != null) 'nationalCode': nationalCode,
      'initialBalance': initialBalance,
      if (creditLimit != null) 'creditLimit': creditLimit,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt,
      if (payments != null) 'payments': payments!.map((p) => p.toJson()).toList(),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? company,
    String? customerType,
    String? phone,
    String? city,
    String? address,
    String? nationalCode,
    double? initialBalance,
    double? creditLimit,
    String? notes,
    int? createdAt,
    List<CustomerPayment>? payments,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      customerType: customerType ?? this.customerType,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      nationalCode: nationalCode ?? this.nationalCode,
      initialBalance: initialBalance ?? this.initialBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      payments: payments ?? this.payments,
    );
  }
}
