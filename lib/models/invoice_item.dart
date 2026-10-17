class InvoiceExpense {
  final String id;
  final String title;
  final double amount;
  final String type; // freight, loss_waste, handling, damage, other
  final String action; // deduct, add, record_only
  final String? sourceAccount; // cash, bank, none
  final String? notes;

  InvoiceExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.action,
    this.sourceAccount,
    this.notes,
  });

  factory InvoiceExpense.fromJson(Map<String, dynamic> json) {
    return InvoiceExpense(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? 'other',
      action: json['action']?.toString() ?? 'deduct',
      sourceAccount: json['sourceAccount']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'action': action,
      if (sourceAccount != null) 'sourceAccount': sourceAccount,
      if (notes != null) 'notes': notes,
    };
  }
}

class InvoiceItem {
  final String id;
  final String productId;
  final String productName;
  final String? category;
  final String unitTitle;
  final int cartonsCount;
  final int? packsCount;
  final int? piecesPerPack;
  final int extraPieces;
  final int piecesPerCarton;
  final int totalPieces;
  final double unitPurchasePrice;
  final double unitSellingPrice;
  final double? coverPrice;
  final double totalPrice;
  final double totalPurchaseCost;
  final double profitAmount;
  final double profitPercentage;
  final String? customDescription;
  final bool? isUnpackaged;
  final bool? isCartonUnknown;

  InvoiceItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.category,
    this.unitTitle = 'عدد',
    this.cartonsCount = 0,
    this.packsCount,
    this.piecesPerPack,
    this.extraPieces = 0,
    this.piecesPerCarton = 1,
    required this.totalPieces,
    required this.unitPurchasePrice,
    required this.unitSellingPrice,
    this.coverPrice,
    required this.totalPrice,
    required this.totalPurchaseCost,
    required this.profitAmount,
    required this.profitPercentage,
    this.customDescription,
    this.isUnpackaged = false,
    this.isCartonUnknown = false,
  });

  factory InvoiceItem.calculate({
    required String id,
    required String productId,
    required String productName,
    String? category,
    String unitTitle = 'عدد',
    int cartonsCount = 0,
    int? packsCount,
    int? piecesPerPack,
    int extraPieces = 0,
    int piecesPerCarton = 1,
    required double unitPurchasePrice,
    required double unitSellingPrice,
    double? coverPrice,
    String? customDescription,
    bool isUnpackaged = false,
    bool isCartonUnknown = false,
  }) {
    final int safePiecesPerCarton = piecesPerCarton > 0 ? piecesPerCarton : 1;
    final int calculatedTotalPieces = (cartonsCount * safePiecesPerCarton) + extraPieces;
    final double calculatedTotalPrice = calculatedTotalPieces * unitSellingPrice;
    final double calculatedTotalCost = calculatedTotalPieces * unitPurchasePrice;
    final double calculatedProfit = calculatedTotalPrice - calculatedTotalCost;
    final double calculatedProfitPct = calculatedTotalCost > 0 ? (calculatedProfit / calculatedTotalCost) * 100 : 0.0;

    return InvoiceItem(
      id: id,
      productId: productId,
      productName: productName,
      category: category,
      unitTitle: unitTitle,
      cartonsCount: cartonsCount,
      packsCount: packsCount,
      piecesPerPack: piecesPerPack,
      extraPieces: extraPieces,
      piecesPerCarton: safePiecesPerCarton,
      totalPieces: calculatedTotalPieces,
      unitPurchasePrice: unitPurchasePrice,
      unitSellingPrice: unitSellingPrice,
      coverPrice: coverPrice,
      totalPrice: calculatedTotalPrice,
      totalPurchaseCost: calculatedTotalCost,
      profitAmount: calculatedProfit,
      profitPercentage: calculatedProfitPct,
      customDescription: customDescription,
      isUnpackaged: isUnpackaged,
      isCartonUnknown: isCartonUnknown,
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      category: json['category']?.toString(),
      unitTitle: json['unitTitle']?.toString() ?? 'عدد',
      cartonsCount: (json['cartonsCount'] as num?)?.toInt() ?? 0,
      packsCount: (json['packsCount'] as num?)?.toInt(),
      piecesPerPack: (json['piecesPerPack'] as num?)?.toInt(),
      extraPieces: (json['extraPieces'] as num?)?.toInt() ?? 0,
      piecesPerCarton: (json['piecesPerCarton'] as num?)?.toInt() ?? 1,
      totalPieces: (json['totalPieces'] as num?)?.toInt() ?? 0,
      unitPurchasePrice: (json['unitPurchasePrice'] as num?)?.toDouble() ?? 0.0,
      unitSellingPrice: (json['unitSellingPrice'] as num?)?.toDouble() ?? 0.0,
      coverPrice: (json['coverPrice'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      totalPurchaseCost: (json['totalPurchaseCost'] as num?)?.toDouble() ?? 0.0,
      profitAmount: (json['profitAmount'] as num?)?.toDouble() ?? 0.0,
      profitPercentage: (json['profitPercentage'] as num?)?.toDouble() ?? 0.0,
      customDescription: json['customDescription']?.toString(),
      isUnpackaged: json['isUnpackaged'] as bool? ?? false,
      isCartonUnknown: json['isCartonUnknown'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      if (category != null) 'category': category,
      'unitTitle': unitTitle,
      'cartonsCount': cartonsCount,
      if (packsCount != null) 'packsCount': packsCount,
      if (piecesPerPack != null) 'piecesPerPack': piecesPerPack,
      'extraPieces': extraPieces,
      'piecesPerCarton': piecesPerCarton,
      'totalPieces': totalPieces,
      'unitPurchasePrice': unitPurchasePrice,
      'unitSellingPrice': unitSellingPrice,
      if (coverPrice != null) 'coverPrice': coverPrice,
      'totalPrice': totalPrice,
      'totalPurchaseCost': totalPurchaseCost,
      'profitAmount': profitAmount,
      'profitPercentage': profitPercentage,
      if (customDescription != null) 'customDescription': customDescription,
      'isUnpackaged': isUnpackaged,
      'isCartonUnknown': isCartonUnknown,
    };
  }
}
