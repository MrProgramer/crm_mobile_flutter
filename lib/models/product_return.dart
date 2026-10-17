class ProductReturn {
  final String id;
  final String productId;
  final String productName;
  final String customerId;
  final String customerName;
  final String? invoiceId;
  final String? invoiceNumber;
  final String type; // to_supplier (برگشت به شرکت) | from_customer (مرجوع از مشتری)
  final int cartonsCount;
  final int extraPieces;
  final int totalPieces;
  final double unitPrice;
  final double totalAmount;
  final double? extraCosts; // کرایه بار / ضایعات کسر شده
  final String? extraCostsReason;
  final double? netAmount; // مبلغ خالص مرجوعی
  final String date;
  final String time;
  final String reason;
  final String? notes;
  final int createdAt;
  final bool? isRefunded;
  final String? refundMethod; // cash, bank, account, invoice_offset
  final String? settlementInvoiceId;
  final String? settlementInvoiceNumber;
  final String? settlementDate;

  ProductReturn({
    required this.id,
    required this.productId,
    required this.productName,
    required this.customerId,
    required this.customerName,
    this.invoiceId,
    this.invoiceNumber,
    required this.type,
    this.cartonsCount = 0,
    this.extraPieces = 0,
    required this.totalPieces,
    required this.unitPrice,
    required this.totalAmount,
    this.extraCosts = 0.0,
    this.extraCostsReason,
    this.netAmount,
    required this.date,
    required this.time,
    required this.reason,
    this.notes,
    required this.createdAt,
    this.isRefunded = false,
    this.refundMethod,
    this.settlementInvoiceId,
    this.settlementInvoiceNumber,
    this.settlementDate,
  });

  double get calculatedNetAmount => netAmount ?? (totalAmount - (extraCosts ?? 0.0));

  factory ProductReturn.fromJson(Map<String, dynamic> json) {
    return ProductReturn(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      invoiceId: json['invoiceId']?.toString(),
      invoiceNumber: json['invoiceNumber']?.toString(),
      type: json['type']?.toString() ?? 'from_customer',
      cartonsCount: (json['cartonsCount'] as num?)?.toInt() ?? 0,
      extraPieces: (json['extraPieces'] as num?)?.toInt() ?? 0,
      totalPieces: (json['totalPieces'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      extraCosts: (json['extraCosts'] as num?)?.toDouble() ?? 0.0,
      extraCostsReason: json['extraCostsReason']?.toString(),
      netAmount: (json['netAmount'] as num?)?.toDouble(),
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      isRefunded: json['isRefunded'] as bool? ?? false,
      refundMethod: json['refundMethod']?.toString(),
      settlementInvoiceId: json['settlementInvoiceId']?.toString(),
      settlementInvoiceNumber: json['settlementInvoiceNumber']?.toString(),
      settlementDate: json['settlementDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'customerId': customerId,
      'customerName': customerName,
      if (invoiceId != null) 'invoiceId': invoiceId,
      if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
      'type': type,
      'cartonsCount': cartonsCount,
      'extraPieces': extraPieces,
      'totalPieces': totalPieces,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'extraCosts': extraCosts,
      if (extraCostsReason != null) 'extraCostsReason': extraCostsReason,
      'netAmount': calculatedNetAmount,
      'date': date,
      'time': time,
      'reason': reason,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt,
      'isRefunded': isRefunded,
      if (refundMethod != null) 'refundMethod': refundMethod,
      if (settlementInvoiceId != null) 'settlementInvoiceId': settlementInvoiceId,
      if (settlementInvoiceNumber != null) 'settlementInvoiceNumber': settlementInvoiceNumber,
      if (settlementDate != null) 'settlementDate': settlementDate,
    };
  }
}
