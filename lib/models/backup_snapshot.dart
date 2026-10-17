class BackupSnapshot {
  final String id;
  final int createdAt;
  final String dateFormatted;
  final String timeFormatted;
  final String type; // change, auto, manual
  final String? changeAction;
  final int productsCount;
  final int invoicesCount;
  final int draftsCount;
  final int customersCount;
  final int paymentsCount;
  final int returnsCount;
  final int treasuryCount;
  final int activityLogsCount;
  final int categoriesCount;
  final int sizeBytes;
  final String? note;
  final Map<String, dynamic> data;

  BackupSnapshot({
    required this.id,
    required this.createdAt,
    required this.dateFormatted,
    required this.timeFormatted,
    required this.type,
    this.changeAction,
    required this.productsCount,
    required this.invoicesCount,
    this.draftsCount = 0,
    required this.customersCount,
    required this.paymentsCount,
    this.returnsCount = 0,
    this.treasuryCount = 0,
    this.activityLogsCount = 0,
    this.categoriesCount = 0,
    required this.sizeBytes,
    this.note,
    required this.data,
  });

  factory BackupSnapshot.fromJson(Map<String, dynamic> json) {
    return BackupSnapshot(
      id: json['id']?.toString() ?? '',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      dateFormatted: json['dateFormatted']?.toString() ?? '',
      timeFormatted: json['timeFormatted']?.toString() ?? '',
      type: json['type']?.toString() ?? 'manual',
      changeAction: json['changeAction']?.toString(),
      productsCount: (json['productsCount'] as num?)?.toInt() ?? 0,
      invoicesCount: (json['invoicesCount'] as num?)?.toInt() ?? 0,
      draftsCount: (json['draftsCount'] as num?)?.toInt() ?? 0,
      customersCount: (json['customersCount'] as num?)?.toInt() ?? 0,
      paymentsCount: (json['paymentsCount'] as num?)?.toInt() ?? 0,
      returnsCount: (json['returnsCount'] as num?)?.toInt() ?? 0,
      treasuryCount: (json['treasuryCount'] as num?)?.toInt() ?? 0,
      activityLogsCount: (json['activityLogsCount'] as num?)?.toInt() ?? 0,
      categoriesCount: (json['categoriesCount'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      note: json['note']?.toString(),
      data: (json['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'dateFormatted': dateFormatted,
      'timeFormatted': timeFormatted,
      'type': type,
      if (changeAction != null) 'changeAction': changeAction,
      'productsCount': productsCount,
      'invoicesCount': invoicesCount,
      'draftsCount': draftsCount,
      'customersCount': customersCount,
      'paymentsCount': paymentsCount,
      'returnsCount': returnsCount,
      'treasuryCount': treasuryCount,
      'activityLogsCount': activityLogsCount,
      'categoriesCount': categoriesCount,
      'sizeBytes': sizeBytes,
      if (note != null) 'note': note,
      'data': data,
    };
  }
}
