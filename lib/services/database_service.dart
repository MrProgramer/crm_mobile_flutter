import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/customer_payment.dart';
import '../models/product_return.dart';
import '../models/treasury_transaction.dart';
import '../models/activity_log.dart';
import '../models/store_settings.dart';
import '../models/backup_snapshot.dart';
import '../utils/formatters.dart';

class DatabaseService {
  static const String keyProducts = 'bazargani_products_v5';
  static const String keyInvoices = 'bazargani_invoices_v6';
  static const String keyCustomers = 'bazargani_customers_v6';
  static const String keyPayments = 'bazargani_payments_v2';
  static const String keyReturns = 'bazargani_returns_v2';
  static const String keyTreasury = 'bazargani_treasury_v1';
  static const String keyActivityLogs = 'bazargani_activity_logs_v1';
  static const String keySettings = 'bazargani_settings_v4';
  static const String keySecretMode = 'bazargani_secret_mode_v3';
  static const String keyBackups = 'bazargani_smart_backup_snapshots_v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Initial Data Defaults (from web app initialData.ts) ---
  List<Product> get defaultProducts => [
        Product(
          id: 'prod-1',
          name: 'آبنبات کپل کوچک توت فرنگی',
          category: 'آبنبات',
          purchasePrice: 4500,
          sellingPrice: 5800,
          coverPrice: 7000,
          piecesPerCarton: 800,
          packsPerCarton: 4,
          piecesPerPack: 200,
          stockPieces: 4000,
          unitTitle: 'عدد',
          notes: 'پرفروش‌ترین محصول قفسه',
        ),
        Product(
          id: 'prod-2',
          name: 'آبنبات جرقه ای الهام',
          category: 'آبنبات',
          purchasePrice: 9000,
          sellingPrice: 10000,
          coverPrice: 12000,
          piecesPerCarton: 672,
          packsPerCarton: 24,
          piecesPerPack: 28,
          stockPieces: 2016,
          unitTitle: 'عدد',
        ),
        Product(
          id: 'prod-3',
          name: 'لواشک نوشابه‌ای ۴۸۰ عددی',
          category: 'لواشک',
          purchasePrice: 6500,
          sellingPrice: 7500,
          coverPrice: 9000,
          piecesPerCarton: 480,
          packsPerCarton: 20,
          piecesPerPack: 24,
          stockPieces: 2400,
          unitTitle: 'عدد',
        ),
      ];

  List<Customer> get defaultCustomers => [
        Customer(
          id: 'cust-1',
          name: 'مدیریت انبار',
          company: 'دفتر مرکزی بازرگانی',
          customerType: 'supplier',
          phone: '09120000000',
          city: 'مرکزی',
          address: 'دفتر مرکزی انبار و لجستیک',
          nationalCode: '10100000000',
          initialBalance: 0,
          creditLimit: 1000000000,
          notes: 'مدیر ارشد مجموعه و مسئول فاکتورهای اصلی ورودی کالا',
          createdAt: DateTime.now().millisecondsSinceEpoch - 86400000 * 30,
        ),
        Customer(
          id: 'cust-2',
          name: 'صابر کریمی',
          company: 'بازرگانی کریمی',
          customerType: 'distributor',
          phone: '09123456789',
          city: 'تهران',
          address: 'بازار بزرگ',
          nationalCode: '1000000000',
          initialBalance: 0,
          creditLimit: 500000000,
          notes: 'مشتری اصلی و عامل پخش',
          createdAt: DateTime.now().millisecondsSinceEpoch - 86400000 * 20,
        ),
        Customer(
          id: 'cust-ali-partovi',
          name: 'علی پرتویی',
          company: 'بازرگانی پرتویی',
          customerType: 'both',
          phone: '09121112233',
          city: 'تهران',
          address: 'بازار بزرگ - خیابان ۱۵ خرداد',
          nationalCode: '1010222333',
          initialBalance: 0,
          creditLimit: 500000000,
          notes: 'طرف‌حساب تجاری خریدار و تأمین‌کننده اصلی',
          createdAt: DateTime.now().millisecondsSinceEpoch - 86400000 * 10,
        ),
      ];

  // --- Products ---
  List<Product> loadProducts() {
    final raw = _prefs.getString(keyProducts);
    if (raw == null || raw.isEmpty) return defaultProducts;
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return defaultProducts;
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
    await _prefs.setString(keyProducts, encoded);
  }

  // --- Invoices ---
  List<Invoice> loadInvoices() {
    final raw = _prefs.getString(keyInvoices);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveInvoices(List<Invoice> invoices) async {
    final encoded = jsonEncode(invoices.map((i) => i.toJson()).toList());
    await _prefs.setString(keyInvoices, encoded);
  }

  // --- Customers ---
  List<Customer> loadCustomers() {
    final raw = _prefs.getString(keyCustomers);
    if (raw == null || raw.isEmpty) return defaultCustomers;
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return defaultCustomers;
    }
  }

  Future<void> saveCustomers(List<Customer> customers) async {
    final encoded = jsonEncode(customers.map((c) => c.toJson()).toList());
    await _prefs.setString(keyCustomers, encoded);
  }

  // --- Payments ---
  List<CustomerPayment> loadPayments() {
    final raw = _prefs.getString(keyPayments);
    if (raw == null || raw.isEmpty) {
      return [
        CustomerPayment(
          id: 'pay-1',
          customerId: 'cust-2',
          customerName: 'صابر کریمی',
          amount: 2500000,
          date: getCurrentPersianDate(),
          time: getCurrentPersianTime(),
          paymentMethod: 'card',
          referenceNumber: '6104-3374-9812',
          description: 'واریزی کارت به کارت بابت تسویه حساب',
          createdAt: DateTime.now().millisecondsSinceEpoch - 86400000 * 3,
        )
      ];
    }
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => CustomerPayment.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePayments(List<CustomerPayment> payments) async {
    final encoded = jsonEncode(payments.map((p) => p.toJson()).toList());
    await _prefs.setString(keyPayments, encoded);
  }

  // --- Returns ---
  List<ProductReturn> loadReturns() {
    final raw = _prefs.getString(keyReturns);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ProductReturn.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReturns(List<ProductReturn> returns) async {
    final encoded = jsonEncode(returns.map((r) => r.toJson()).toList());
    await _prefs.setString(keyReturns, encoded);
  }

  // --- Treasury ---
  List<TreasuryTransaction> loadTreasury() {
    final raw = _prefs.getString(keyTreasury);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => TreasuryTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTreasury(List<TreasuryTransaction> transactions) async {
    final encoded = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await _prefs.setString(keyTreasury, encoded);
  }

  // --- Activity Logs ---
  List<ActivityLog> loadActivityLogs() {
    final raw = _prefs.getString(keyActivityLogs);
    if (raw == null || raw.isEmpty) {
      return [
        ActivityLog(
          id: 'log-1',
          title: 'سامانه آماده به کار',
          description: 'اتوماسیون انبارداری و بازرگانی آماده ثبت اطلاعات گردید.',
          date: getCurrentPersianDate(),
          time: getCurrentPersianTime(),
          timestamp: DateTime.now().millisecondsSinceEpoch,
          type: 'system',
        )
      ];
    }
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ActivityLog.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveActivityLogs(List<ActivityLog> logs) async {
    final encoded = jsonEncode(logs.map((l) => l.toJson()).toList());
    await _prefs.setString(keyActivityLogs, encoded);
  }

  // --- Store Settings ---
  StoreSettings loadSettings() {
    final raw = _prefs.getString(keySettings);
    if (raw == null || raw.isEmpty) return StoreSettings();
    try {
      return StoreSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return StoreSettings();
    }
  }

  Future<void> saveSettings(StoreSettings settings) async {
    final encoded = jsonEncode(settings.toJson());
    await _prefs.setString(keySettings, encoded);
  }

  // --- Secret Mode ---
  bool loadSecretMode() {
    return _prefs.getBool(keySecretMode) ?? false;
  }

  Future<void> saveSecretMode(bool value) async {
    await _prefs.setBool(keySecretMode, value);
  }

  // --- Snapshots ---
  List<BackupSnapshot> loadSnapshots() {
    final raw = _prefs.getString(keyBackups);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => BackupSnapshot.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSnapshots(List<BackupSnapshot> snapshots) async {
    final encoded = jsonEncode(snapshots.map((s) => s.toJson()).toList());
    await _prefs.setString(keyBackups, encoded);
  }
}
