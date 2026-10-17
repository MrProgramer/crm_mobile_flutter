class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String cardNumber;
  final String iban;
  final bool isDefault;
  final String? holderName;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.cardNumber,
    required this.iban,
    this.isDefault = false,
    this.holderName,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      cardNumber: json['cardNumber']?.toString() ?? '',
      iban: json['iban']?.toString() ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      holderName: json['holderName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'cardNumber': cardNumber,
      'iban': iban,
      'isDefault': isDefault,
      if (holderName != null) 'holderName': holderName,
    };
  }
}

class StoreSettings {
  final String brandName;
  final String? storeNameFa;
  final String subtitle;
  final String bismillah;
  final String phone;
  final String address;
  final String bankName;
  final String accountNumber;
  final String cardNumber;
  final String iban;
  final List<BankAccount>? bankAccounts;
  final String minOrderNotice;
  final String sellerStampName;
  final String themeColor;
  final String designMode;
  final String fontFamily;
  final String numberFormat;
  final String fontSizeScale;
  final String invoiceFontSizeScale;
  final bool enableWatermark;
  final String watermarkText;
  final bool showSignatureArea;
  final bool? showStamp;
  final String? stampText;
  final String? stampColor;
  final String? stampShape;
  final String? adminPin;
  final bool enableBiometrics;
  final bool requireAuthForInvoiceActions;
  final bool? requirePinForEdit;
  final bool? requirePinForDelete;
  final bool? hideConfidentialPrices;
  final bool? defaultShowCoverPrice;
  final bool enableAutoBackup;
  final int autoBackupIntervalHours;
  final int backupRetentionCount;
  final int? lastAutoBackupTimestamp;
  final String? lastBackupDateFormatted;
  final String? appLogo;

  StoreSettings({
    this.brandName = 'بازرگانی',
    this.storeNameFa = 'دفتر بازرگانی و انبار مرکزی',
    this.subtitle = 'فاکتور فروش کالا و خدمات',
    this.bismillah = 'هوالرزاق',
    this.phone = '09120000000',
    this.address = 'دفتر مرکزی بازرگانی و انبار',
    this.bankName = 'بانک ملت',
    this.accountNumber = '8349183105',
    this.cardNumber = '6104337420672725',
    this.iban = 'IR 470120010000008349183105',
    this.bankAccounts,
    this.minOrderNotice = '',
    this.sellerStampName = 'مدیریت بازرگانی',
    this.themeColor = 'black',
    this.designMode = 'modern',
    this.fontFamily = 'vazirmatn',
    this.numberFormat = 'persian',
    this.fontSizeScale = 'standard',
    this.invoiceFontSizeScale = 'standard',
    this.enableWatermark = true,
    this.watermarkText = 'بازرگانی',
    this.showSignatureArea = true,
    this.showStamp = true,
    this.stampText = 'تایید شد',
    this.stampColor = 'blue',
    this.stampShape = 'circle',
    this.adminPin = '1234',
    this.enableBiometrics = false,
    this.requireAuthForInvoiceActions = true,
    this.requirePinForEdit = false,
    this.requirePinForDelete = true,
    this.hideConfidentialPrices = false,
    this.defaultShowCoverPrice = true,
    this.enableAutoBackup = true,
    this.autoBackupIntervalHours = 24,
    this.backupRetentionCount = 5,
    this.lastAutoBackupTimestamp,
    this.lastBackupDateFormatted = 'پشتیبان‌گیری خودکار فعال',
    this.appLogo,
  });

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    var rawAccounts = json['bankAccounts'] as List<dynamic>?;
    List<BankAccount>? parsedAccounts = rawAccounts
        ?.map((a) => BankAccount.fromJson(a as Map<String, dynamic>))
        .toList();

    return StoreSettings(
      brandName: json['brandName']?.toString() ?? 'بازرگانی',
      storeNameFa: json['storeNameFa']?.toString() ?? 'دفتر بازرگانی و انبار مرکزی',
      subtitle: json['subtitle']?.toString() ?? 'فاکتور فروش کالا و خدمات',
      bismillah: json['bismillah']?.toString() ?? 'هوالرزاق',
      phone: json['phone']?.toString() ?? '09120000000',
      address: json['address']?.toString() ?? 'دفتر مرکزی بازرگانی و انبار',
      bankName: json['bankName']?.toString() ?? 'بانک ملت',
      accountNumber: json['accountNumber']?.toString() ?? '',
      cardNumber: json['cardNumber']?.toString() ?? '',
      iban: json['iban']?.toString() ?? '',
      bankAccounts: parsedAccounts,
      minOrderNotice: json['minOrderNotice']?.toString() ?? '',
      sellerStampName: json['sellerStampName']?.toString() ?? 'مدیریت بازرگانی',
      themeColor: json['themeColor']?.toString() ?? 'black',
      designMode: json['designMode']?.toString() ?? 'modern',
      fontFamily: json['fontFamily']?.toString() ?? 'vazirmatn',
      numberFormat: json['numberFormat']?.toString() ?? 'persian',
      fontSizeScale: json['fontSizeScale']?.toString() ?? 'standard',
      invoiceFontSizeScale: json['invoiceFontSizeScale']?.toString() ?? 'standard',
      enableWatermark: json['enableWatermark'] as bool? ?? true,
      watermarkText: json['watermarkText']?.toString() ?? 'بازرگانی',
      showSignatureArea: json['showSignatureArea'] as bool? ?? true,
      showStamp: json['showStamp'] as bool? ?? true,
      stampText: json['stampText']?.toString() ?? 'تایید شد',
      stampColor: json['stampColor']?.toString() ?? 'blue',
      stampShape: json['stampShape']?.toString() ?? 'circle',
      adminPin: json['adminPin']?.toString() ?? '1234',
      enableBiometrics: json['enableBiometrics'] as bool? ?? false,
      requireAuthForInvoiceActions: json['requireAuthForInvoiceActions'] as bool? ?? true,
      requirePinForEdit: json['requirePinForEdit'] as bool? ?? false,
      requirePinForDelete: json['requirePinForDelete'] as bool? ?? true,
      hideConfidentialPrices: json['hideConfidentialPrices'] as bool? ?? false,
      defaultShowCoverPrice: json['defaultShowCoverPrice'] as bool? ?? true,
      enableAutoBackup: json['enableAutoBackup'] as bool? ?? true,
      autoBackupIntervalHours: (json['autoBackupIntervalHours'] as num?)?.toInt() ?? 24,
      backupRetentionCount: (json['backupRetentionCount'] as num?)?.toInt() ?? 5,
      lastAutoBackupTimestamp: (json['lastAutoBackupTimestamp'] as num?)?.toInt(),
      lastBackupDateFormatted: json['lastBackupDateFormatted']?.toString() ?? 'پشتیبان‌گیری فعال',
      appLogo: json['appLogo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brandName': brandName,
      if (storeNameFa != null) 'storeNameFa': storeNameFa,
      'subtitle': subtitle,
      'bismillah': bismillah,
      'phone': phone,
      'address': address,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'cardNumber': cardNumber,
      'iban': iban,
      if (bankAccounts != null) 'bankAccounts': bankAccounts!.map((a) => a.toJson()).toList(),
      'minOrderNotice': minOrderNotice,
      'sellerStampName': sellerStampName,
      'themeColor': themeColor,
      'designMode': designMode,
      'fontFamily': fontFamily,
      'numberFormat': numberFormat,
      'fontSizeScale': fontSizeScale,
      'invoiceFontSizeScale': invoiceFontSizeScale,
      'enableWatermark': enableWatermark,
      'watermarkText': watermarkText,
      'showSignatureArea': showSignatureArea,
      'showStamp': showStamp,
      'stampText': stampText,
      'stampColor': stampColor,
      'stampShape': stampShape,
      'adminPin': adminPin,
      'enableBiometrics': enableBiometrics,
      'requireAuthForInvoiceActions': requireAuthForInvoiceActions,
      'requirePinForEdit': requirePinForEdit,
      'requirePinForDelete': requirePinForDelete,
      'hideConfidentialPrices': hideConfidentialPrices,
      'defaultShowCoverPrice': defaultShowCoverPrice,
      'enableAutoBackup': enableAutoBackup,
      'autoBackupIntervalHours': autoBackupIntervalHours,
      'backupRetentionCount': backupRetentionCount,
      if (lastAutoBackupTimestamp != null) 'lastAutoBackupTimestamp': lastAutoBackupTimestamp,
      if (lastBackupDateFormatted != null) 'lastBackupDateFormatted': lastBackupDateFormatted,
      if (appLogo != null) 'appLogo': appLogo,
    };
  }

  StoreSettings copyWith({
    String? brandName,
    String? storeNameFa,
    String? subtitle,
    String? bismillah,
    String? phone,
    String? address,
    String? bankName,
    String? accountNumber,
    String? cardNumber,
    String? iban,
    List<BankAccount>? bankAccounts,
    String? minOrderNotice,
    String? sellerStampName,
    String? themeColor,
    String? designMode,
    String? fontFamily,
    String? numberFormat,
    String? fontSizeScale,
    String? invoiceFontSizeScale,
    bool? enableWatermark,
    String? watermarkText,
    bool? showSignatureArea,
    bool? showStamp,
    String? stampText,
    String? stampColor,
    String? stampShape,
    String? adminPin,
    bool? enableBiometrics,
    bool? requireAuthForInvoiceActions,
    bool? requirePinForEdit,
    bool? requirePinForDelete,
    bool? hideConfidentialPrices,
    bool? defaultShowCoverPrice,
    bool? enableAutoBackup,
    int? autoBackupIntervalHours,
    int? backupRetentionCount,
    int? lastAutoBackupTimestamp,
    String? lastBackupDateFormatted,
    String? appLogo,
  }) {
    return StoreSettings(
      brandName: brandName ?? this.brandName,
      storeNameFa: storeNameFa ?? this.storeNameFa,
      subtitle: subtitle ?? this.subtitle,
      bismillah: bismillah ?? this.bismillah,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      cardNumber: cardNumber ?? this.cardNumber,
      iban: iban ?? this.iban,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      minOrderNotice: minOrderNotice ?? this.minOrderNotice,
      sellerStampName: sellerStampName ?? this.sellerStampName,
      themeColor: themeColor ?? this.themeColor,
      designMode: designMode ?? this.designMode,
      fontFamily: fontFamily ?? this.fontFamily,
      numberFormat: numberFormat ?? this.numberFormat,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      invoiceFontSizeScale: invoiceFontSizeScale ?? this.invoiceFontSizeScale,
      enableWatermark: enableWatermark ?? this.enableWatermark,
      watermarkText: watermarkText ?? this.watermarkText,
      showSignatureArea: showSignatureArea ?? this.showSignatureArea,
      showStamp: showStamp ?? this.showStamp,
      stampText: stampText ?? this.stampText,
      stampColor: stampColor ?? this.stampColor,
      stampShape: stampShape ?? this.stampShape,
      adminPin: adminPin ?? this.adminPin,
      enableBiometrics: enableBiometrics ?? this.enableBiometrics,
      requireAuthForInvoiceActions: requireAuthForInvoiceActions ?? this.requireAuthForInvoiceActions,
      requirePinForEdit: requirePinForEdit ?? this.requirePinForEdit,
      requirePinForDelete: requirePinForDelete ?? this.requirePinForDelete,
      hideConfidentialPrices: hideConfidentialPrices ?? this.hideConfidentialPrices,
      defaultShowCoverPrice: defaultShowCoverPrice ?? this.defaultShowCoverPrice,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      autoBackupIntervalHours: autoBackupIntervalHours ?? this.autoBackupIntervalHours,
      backupRetentionCount: backupRetentionCount ?? this.backupRetentionCount,
      lastAutoBackupTimestamp: lastAutoBackupTimestamp ?? this.lastAutoBackupTimestamp,
      lastBackupDateFormatted: lastBackupDateFormatted ?? this.lastBackupDateFormatted,
      appLogo: appLogo ?? this.appLogo,
    );
  }
}
