import 'invoice_item.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final String date;
  final String time;
  final int? timestamp;
  final String type; // sale, purchase
  final String? paymentStatus; // cash, credit, partial
  final double? paidAmount;
  final double? remainingAmount;
  final String? paymentAccount; // cash, bank
  final String? paymentMethodDetails;
  final bool isDraft;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String customerCity;
  final String? customerAddress;
  final String? customerType;
  final String salesType;
  final String paymentMethod;
  final String previousBalance;
  final String finalCustomerBalance;
  final List<InvoiceItem> items;
  final double subtotal;
  final double discount;
  final bool hasDiscount;
  final double? discountPercent;
  final bool showCoverPrice;
  final double tax;
  final double finalAmount;
  final List<String>? offsetReturnIds;
  final double? offsetReturnsTotal;
  final List<InvoiceExpense>? expenses;
  final double? expensesTotalDeduction;
  final double? expensesTotalAddition;
  final String? notes;
  final int createdAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.time,
    this.timestamp,
    required this.type,
    this.paymentStatus,
    this.paidAmount,
    this.remainingAmount,
    this.paymentAccount,
    this.paymentMethodDetails,
    this.isDraft = false,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerCity,
    this.customerAddress,
    this.customerType,
    required this.salesType,
    required this.paymentMethod,
    this.previousBalance = 'بی‌حساب',
    this.finalCustomerBalance = 'تسویه شده / بی‌حساب',
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.hasDiscount = false,
    this.discountPercent,
    this.showCoverPrice = true,
    this.tax = 0.0,
    required this.finalAmount,
    this.offsetReturnIds,
    this.offsetReturnsTotal,
    this.expenses,
    this.expensesTotalDeduction,
    this.expensesTotalAddition,
    this.notes,
    required this.createdAt,
  });

  int get totalCartons => items.fold(0, (sum, it) => sum + it.cartonsCount);
  int get totalPieces => items.fold(0, (sum, it) => sum + it.totalPieces);
  double get totalProfit => items.fold(0.0, (sum, it) => sum + it.profitAmount);
  double get totalPurchaseCost => items.fold(0.0, (sum, it) => sum + it.totalPurchaseCost);

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List<dynamic>? ?? [];
    List<InvoiceItem> parsedItems = rawItems
        .map((itemJson) => InvoiceItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    var rawExpenses = json['expenses'] as List<dynamic>?;
    List<InvoiceExpense>? parsedExpenses = rawExpenses
        ?.map((e) => InvoiceExpense.fromJson(e as Map<String, dynamic>))
        .toList();

    var rawOffsets = json['offsetReturnIds'] as List<dynamic>?;
    List<String>? parsedOffsets = rawOffsets?.map((e) => e.toString()).toList();

    return Invoice(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '1001',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt(),
      type: json['type']?.toString() ?? 'sale',
      paymentStatus: json['paymentStatus']?.toString(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble(),
      paymentAccount: json['paymentAccount']?.toString(),
      paymentMethodDetails: json['paymentMethodDetails']?.toString(),
      isDraft: json['isDraft'] as bool? ?? false,
      customerId: json['customerId']?.toString(),
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      customerCity: json['customerCity']?.toString() ?? '',
      customerAddress: json['customerAddress']?.toString(),
      customerType: json['customerType']?.toString(),
      salesType: json['salesType']?.toString() ?? 'نقدی عادی',
      paymentMethod: json['paymentMethod']?.toString() ?? 'نقدی (تسویه شده)',
      previousBalance: json['previousBalance']?.toString() ?? 'بی‌حساب',
      finalCustomerBalance: json['finalCustomerBalance']?.toString() ?? 'تسویه شده / بی‌حساب',
      items: parsedItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      hasDiscount: json['hasDiscount'] as bool? ?? false,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      showCoverPrice: json['showCoverPrice'] as bool? ?? true,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
      offsetReturnIds: parsedOffsets,
      offsetReturnsTotal: (json['offsetReturnsTotal'] as num?)?.toDouble(),
      expenses: parsedExpenses,
      expensesTotalDeduction: (json['expensesTotalDeduction'] as num?)?.toDouble(),
      expensesTotalAddition: (json['expensesTotalAddition'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'date': date,
      'time': time,
      if (timestamp != null) 'timestamp': timestamp,
      'type': type,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (paidAmount != null) 'paidAmount': paidAmount,
      if (remainingAmount != null) 'remainingAmount': remainingAmount,
      if (paymentAccount != null) 'paymentAccount': paymentAccount,
      if (paymentMethodDetails != null) 'paymentMethodDetails': paymentMethodDetails,
      'isDraft': isDraft,
      if (customerId != null) 'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerCity': customerCity,
      if (customerAddress != null) 'customerAddress': customerAddress,
      if (customerType != null) 'customerType': customerType,
      'salesType': salesType,
      'paymentMethod': paymentMethod,
      'previousBalance': previousBalance,
      'finalCustomerBalance': finalCustomerBalance,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'hasDiscount': hasDiscount,
      if (discountPercent != null) 'discountPercent': discountPercent,
      'showCoverPrice': showCoverPrice,
      'tax': tax,
      'finalAmount': finalAmount,
      if (offsetReturnIds != null) 'offsetReturnIds': offsetReturnIds,
      if (offsetReturnsTotal != null) 'offsetReturnsTotal': offsetReturnsTotal,
      if (expenses != null) 'expenses': expenses!.map((e) => e.toJson()).toList(),
      if (expensesTotalDeduction != null) 'expensesTotalDeduction': expensesTotalDeduction,
      if (expensesTotalAddition != null) 'expensesTotalAddition': expensesTotalAddition,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt,
    };
  }
}
