import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/customer.dart';
import '../models/customer_payment.dart';
import '../models/product_return.dart';
import '../models/treasury_transaction.dart';
import '../models/activity_log.dart';
import '../models/store_settings.dart';
import '../models/backup_snapshot.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../utils/calculations.dart';

class AppState extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<Product> _products = [];
  List<Invoice> _invoices = [];
  List<Customer> _customers = [];
  List<CustomerPayment> _payments = [];
  List<ProductReturn> _returns = [];
  List<TreasuryTransaction> _treasury = [];
  List<ActivityLog> _activityLogs = [];
  List<BackupSnapshot> _snapshots = [];
  StoreSettings _settings = StoreSettings();

  bool _isSecretMode = false;
  bool _isDarkMode = false;
  int _currentBottomNavIndex = 0;

  List<Product> get products => _products;
  List<Invoice> get invoices => _invoices;
  List<Customer> get customers => _customers;
  List<CustomerPayment> get payments => _payments;
  List<ProductReturn> get returns => _returns;
  List<TreasuryTransaction> get treasury => _treasury;
  List<ActivityLog> get activityLogs => _activityLogs;
  List<BackupSnapshot> get snapshots => _snapshots;
  StoreSettings get settings => _settings;
  bool get isSecretMode => _isSecretMode;
  bool get isDarkMode => _isDarkMode;
  int get currentBottomNavIndex => _currentBottomNavIndex;

  void setBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    notifyListeners();
  }

  Future<void> init() async {
    await _db.init();
    _products = _db.loadProducts();
    _invoices = _db.loadInvoices();
    _customers = _db.loadCustomers();
    _payments = _db.loadPayments();
    _returns = _db.loadReturns();
    _treasury = _db.loadTreasury();
    _activityLogs = _db.loadActivityLogs();
    _snapshots = _db.loadSnapshots();
    _settings = _db.loadSettings();
    _isSecretMode = _db.loadSecretMode();
    _isInitialized = true;
    notifyListeners();
  }

  void toggleSecretMode() {
    _isSecretMode = !_isSecretMode;
    _db.saveSecretMode(_isSecretMode);
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // --- Activity Logging Helper ---
  void _addLog({
    required String title,
    required String description,
    String type = 'system',
    String? tabTarget,
  }) {
    final log = ActivityLog(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 4)}',
      title: title,
      description: description,
      date: getCurrentPersianDate(),
      time: getCurrentPersianTime(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: type,
      tabTarget: tabTarget,
    );
    _activityLogs.insert(0, log);
    if (_activityLogs.length > 100) {
      _activityLogs = _activityLogs.sublist(0, 100);
    }
    _db.saveActivityLogs(_activityLogs);
  }

  // --- Snapshot Helper ---
  void _createOnChangeSnapshot(String changeDescription) {
    final snap = generateSnapshotObject(type: 'change', note: changeDescription);
    _snapshots.insert(0, snap);
    if (_snapshots.length > 15) {
      _snapshots = _snapshots.sublist(0, 15);
    }
    _db.saveSnapshots(_snapshots);
  }

  BackupSnapshot generateSnapshotObject({String type = 'manual', String? note}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final draftInvoices = _invoices.where((i) => i.isDraft).toList();
    final salesInvoices = _invoices.where((i) => !i.isDraft && i.type == 'sale').toList();
    final purchaseInvoices = _invoices.where((i) => !i.isDraft && i.type == 'purchase').toList();

    final dataPayload = {
      'version': '2.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'summary': {
        'productsCount': _products.length,
        'invoicesCount': _invoices.length,
        'draftsCount': draftInvoices.length,
        'salesCount': salesInvoices.length,
        'purchasesCount': purchaseInvoices.length,
        'customersCount': _customers.length,
        'paymentsCount': _payments.length,
        'returnsCount': _returns.length,
        'treasuryCount': _treasury.length,
        'activityLogsCount': _activityLogs.length,
      },
      'products': _products.map((p) => p.toJson()).toList(),
      'invoices': _invoices.map((i) => i.toJson()).toList(),
      'draftInvoices': draftInvoices.map((i) => i.toJson()).toList(),
      'drafts': draftInvoices.map((i) => i.toJson()).toList(),
      'customers': _customers.map((c) => c.toJson()).toList(),
      'payments': _payments.map((p) => p.toJson()).toList(),
      'customerPayments': _payments.map((p) => p.toJson()).toList(),
      'paymentsList': _payments.map((p) => p.toJson()).toList(),
      'productReturns': _returns.map((r) => r.toJson()).toList(),
      'returns': _returns.map((r) => r.toJson()).toList(),
      'treasuryTransactions': _treasury.map((t) => t.toJson()).toList(),
      'treasury': _treasury.map((t) => t.toJson()).toList(),
      'liquidity': _treasury.map((t) => t.toJson()).toList(),
      'activityLogs': _activityLogs.map((l) => l.toJson()).toList(),
      'settings': _settings.toJson(),
    };

    final rawJson = jsonEncode(dataPayload);
    final sizeBytes = utf8.encode(rawJson).length;

    return BackupSnapshot(
      id: 'backup-$timestamp-${_uuid.v4().substring(0, 5)}',
      createdAt: timestamp,
      dateFormatted: getCurrentPersianDate(),
      timeFormatted: getCurrentPersianTime(),
      type: type,
      changeAction: note ?? 'پشتیبان هوشمند برنامه',
      productsCount: _products.length,
      invoicesCount: _invoices.length,
      draftsCount: draftInvoices.length,
      customersCount: _customers.length,
      paymentsCount: _payments.length,
      returnsCount: _returns.length,
      treasuryCount: _treasury.length,
      activityLogsCount: _activityLogs.length,
      sizeBytes: sizeBytes,
      note: note,
      data: dataPayload,
    );
  }

  // --- Products CRUD ---
  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    await _db.saveProducts(_products);
    _addLog(
      title: 'افزودن کالای جدید',
      description: 'کالای "${product.name}" به موجودی انبار افزوده شد.',
      type: 'product',
      tabTarget: 'inventory',
    );
    _createOnChangeSnapshot('افزودن کالای ${product.name}');
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await _db.saveProducts(_products);
      _addLog(
        title: 'ویرایش کالا',
        description: 'مشخصات کالای "${product.name}" به‌روزرسانی شد.',
        type: 'product',
        tabTarget: 'inventory',
      );
      _createOnChangeSnapshot('ویرایش کالای ${product.name}');
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    final prod = _products.firstWhere((p) => p.id == productId, orElse: () => _products.first);
    _products.removeWhere((p) => p.id == productId);
    await _db.saveProducts(_products);
    _addLog(
      title: 'حذف کالا',
      description: 'کالای "${prod.name}" از انبار حذف گردید.',
      type: 'product',
      tabTarget: 'inventory',
    );
    _createOnChangeSnapshot('حذف کالای ${prod.name}');
    notifyListeners();
  }

  /// Inward cargo / recharge stock directly
  Future<void> inwardStock({
    required String productId,
    required int addedPieces,
    double? newPurchasePrice,
    double? newSellingPrice,
  }) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final old = _products[index];
      final updated = old.copyWith(
        stockPieces: old.stockPieces + addedPieces,
        purchasePrice: newPurchasePrice ?? old.purchasePrice,
        sellingPrice: newSellingPrice ?? old.sellingPrice,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      _products[index] = updated;
      await _db.saveProducts(_products);
      _addLog(
        title: 'ورود بار به انبار',
        description: 'شارژ موجودی کالای "${old.name}" به تعداد $addedPieces عدد',
        type: 'product',
        tabTarget: 'inventory',
      );
      _createOnChangeSnapshot('ورود بار به انبار: ${old.name}');
      notifyListeners();
    }
  }

  // --- Invoices CRUD ---
  Future<void> addInvoice(Invoice invoice) async {
    _invoices.insert(0, invoice);

    // Apply inventory change if not draft
    if (!invoice.isDraft) {
      for (final item in invoice.items) {
        final pIdx = _products.indexWhere((p) => p.id == item.productId);
        if (pIdx != -1) {
          final prod = _products[pIdx];
          int newStock = prod.stockPieces;
          if (invoice.type == 'sale') {
            newStock = (prod.stockPieces - item.totalPieces).clamp(0, 999999999);
          } else if (invoice.type == 'purchase') {
            newStock = prod.stockPieces + item.totalPieces;
          }
          _products[pIdx] = prod.copyWith(stockPieces: newStock);
        }
      }
      await _db.saveProducts(_products);
    }

    await _db.saveInvoices(_invoices);
    _addLog(
      title: invoice.type == 'sale' ? 'صدور فاکتور فروش' : 'ثبت فاکتور خرید',
      description: 'فاکتور شماره ${invoice.invoiceNumber} به مبلغ ${formatPrice(invoice.finalAmount, showUnit: true)} برای ${invoice.customerName}',
      type: 'invoice',
      tabTarget: 'invoices',
    );
    _createOnChangeSnapshot('ثبت فاکتور شماره ${invoice.invoiceNumber}');
    notifyListeners();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final index = _invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      final oldInv = _invoices[index];

      // Revert old inventory change if old wasn't draft
      if (!oldInv.isDraft) {
        for (final item in oldInv.items) {
          final pIdx = _products.indexWhere((p) => p.id == item.productId);
          if (pIdx != -1) {
            final prod = _products[pIdx];
            int stock = prod.stockPieces;
            if (oldInv.type == 'sale') {
              stock += item.totalPieces;
            } else if (oldInv.type == 'purchase') {
              stock = (stock - item.totalPieces).clamp(0, 999999999);
            }
            _products[pIdx] = prod.copyWith(stockPieces: stock);
          }
        }
      }

      // Apply new inventory change if new isn't draft
      if (!invoice.isDraft) {
        for (final item in invoice.items) {
          final pIdx = _products.indexWhere((p) => p.id == item.productId);
          if (pIdx != -1) {
            final prod = _products[pIdx];
            int stock = prod.stockPieces;
            if (invoice.type == 'sale') {
              stock = (stock - item.totalPieces).clamp(0, 999999999);
            } else if (invoice.type == 'purchase') {
              stock += item.totalPieces;
            }
            _products[pIdx] = prod.copyWith(stockPieces: stock);
          }
        }
      }

      _invoices[index] = invoice;
      await _db.saveProducts(_products);
      await _db.saveInvoices(_invoices);
      _addLog(
        title: 'ویرایش فاکتور',
        description: 'فاکتور شماره ${invoice.invoiceNumber} ویرایش و به‌روزرسانی شد.',
        type: 'invoice',
        tabTarget: 'invoices',
      );
      _createOnChangeSnapshot('ویرایش فاکتور شماره ${invoice.invoiceNumber}');
      notifyListeners();
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    final inv = _invoices.firstWhere((i) => i.id == invoiceId, orElse: () => _invoices.first);

    // Revert inventory
    if (!inv.isDraft) {
      for (final item in inv.items) {
        final pIdx = _products.indexWhere((p) => p.id == item.productId);
        if (pIdx != -1) {
          final prod = _products[pIdx];
          int stock = prod.stockPieces;
          if (inv.type == 'sale') {
            stock += item.totalPieces;
          } else if (inv.type == 'purchase') {
            stock = (stock - item.totalPieces).clamp(0, 999999999);
          }
          _products[pIdx] = prod.copyWith(stockPieces: stock);
        }
      }
      await _db.saveProducts(_products);
    }

    _invoices.removeWhere((i) => i.id == invoiceId);
    await _db.saveInvoices(_invoices);
    _addLog(
      title: 'حذف فاکتور',
      description: 'فاکتور شماره ${inv.invoiceNumber} از بایگانی حذف شد.',
      type: 'invoice',
      tabTarget: 'invoices',
    );
    _createOnChangeSnapshot('حذف فاکتور شماره ${inv.invoiceNumber}');
    notifyListeners();
  }

  // --- Customers CRUD ---
  Future<void> addCustomer(Customer customer) async {
    _customers.insert(0, customer);
    await _db.saveCustomers(_customers);
    _addLog(
      title: 'ثبت طرف حساب جدید',
      description: 'طرف حساب "${customer.name}" ثبت گردید.',
      type: 'customer',
      tabTarget: 'customers',
    );
    _createOnChangeSnapshot('ثبت طرف حساب ${customer.name}');
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      await _db.saveCustomers(_customers);
      _addLog(
        title: 'ویرایش طرف حساب',
        description: 'مشخصات "${customer.name}" به‌روزرسانی گردید.',
        type: 'customer',
        tabTarget: 'customers',
      );
      _createOnChangeSnapshot('ویرایش طرف حساب ${customer.name}');
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    final cust = _customers.firstWhere((c) => c.id == customerId, orElse: () => _customers.first);
    _customers.removeWhere((c) => c.id == customerId);
    await _db.saveCustomers(_customers);
    _addLog(
      title: 'حذف طرف حساب',
      description: 'طرف حساب "${cust.name}" حذف شد.',
      type: 'customer',
      tabTarget: 'customers',
    );
    _createOnChangeSnapshot('حذف طرف حساب ${cust.name}');
    notifyListeners();
  }

  // --- Payments CRUD ---
  Future<void> addPayment(CustomerPayment payment) async {
    _payments.insert(0, payment);
    await _db.savePayments(_payments);
    _addLog(
      title: 'ثبت تراکنش مالی / واریزی',
      description: 'مبلغ ${formatPrice(payment.amount, showUnit: true)} برای ${payment.customerName}',
      type: 'payment',
      tabTarget: 'customers',
    );
    _createOnChangeSnapshot('ثبت واریزی ${payment.customerName}');
    notifyListeners();
  }

  Future<void> deletePayment(String paymentId) async {
    _payments.removeWhere((p) => p.id == paymentId);
    await _db.savePayments(_payments);
    _addLog(
      title: 'حذف تراکنش مالی',
      description: 'تراکنش مالی حذف گردید.',
      type: 'payment',
      tabTarget: 'customers',
    );
    _createOnChangeSnapshot('حذف تراکنش مالی');
    notifyListeners();
  }

  // --- Returns CRUD ---
  Future<void> addReturn(ProductReturn ret) async {
    _returns.insert(0, ret);

    // Stock adjustment:
    // If return from customer: goods come back into our inventory (+)
    // If return to supplier: goods leave our warehouse (-)
    final pIdx = _products.indexWhere((p) => p.id == ret.productId);
    if (pIdx != -1) {
      final p = _products[pIdx];
      int stock = p.stockPieces;
      if (ret.type == 'from_customer') {
        stock += ret.totalPieces;
      } else {
        stock = (stock - ret.totalPieces).clamp(0, 999999999);
      }
      _products[pIdx] = p.copyWith(stockPieces: stock);
      await _db.saveProducts(_products);
    }

    await _db.saveReturns(_returns);
    _addLog(
      title: ret.type == 'from_customer' ? 'مرجوعی از مشتری' : 'برگشت کالا به شرکت',
      description: 'کالای ${ret.productName} به تعداد ${ret.totalPieces} دانه',
      type: 'return',
      tabTarget: 'returns',
    );
    _createOnChangeSnapshot('ثبت مرجوعی ${ret.productName}');
    notifyListeners();
  }

  Future<void> deleteReturn(String returnId) async {
    final ret = _returns.firstWhere((r) => r.id == returnId, orElse: () => _returns.first);

    // Revert stock
    final pIdx = _products.indexWhere((p) => p.id == ret.productId);
    if (pIdx != -1) {
      final p = _products[pIdx];
      int stock = p.stockPieces;
      if (ret.type == 'from_customer') {
        stock = (stock - ret.totalPieces).clamp(0, 999999999);
      } else {
        stock += ret.totalPieces;
      }
      _products[pIdx] = p.copyWith(stockPieces: stock);
      await _db.saveProducts(_products);
    }

    _returns.removeWhere((r) => r.id == returnId);
    await _db.saveReturns(_returns);
    _createOnChangeSnapshot('حذف سند مرجوعی');
    notifyListeners();
  }

  // --- Treasury CRUD ---
  Future<void> addTreasuryTransaction(TreasuryTransaction tx) async {
    _treasury.insert(0, tx);
    await _db.saveTreasury(_treasury);
    _addLog(
      title: tx.type == 'expense'
          ? 'ثبت هزینه انبار'
          : (tx.type == 'transfer' ? 'انتقال بین حساب' : 'افزایش موجودی'),
      description: 'مبلغ ${formatPrice(tx.amount, showUnit: true)} - ${tx.description}',
      type: 'system',
      tabTarget: 'liquidity',
    );
    _createOnChangeSnapshot('ثبت سند خزانه: ${tx.description}');
    notifyListeners();
  }

  Future<void> deleteTreasuryTransaction(String txId) async {
    _treasury.removeWhere((t) => t.id == txId);
    await _db.saveTreasury(_treasury);
    _createOnChangeSnapshot('حذف سند خزانه');
    notifyListeners();
  }

  // --- Settings ---
  Future<void> updateSettings(StoreSettings newSettings) async {
    _settings = newSettings;
    await _db.saveSettings(_settings);
    _addLog(
      title: 'به‌روزرسانی تنظیمات',
      description: 'تنظیمات سامانه و مشخصات بازرگانی تغییر یافت.',
      type: 'system',
    );
    notifyListeners();
  }

  // --- Import Full JSON Database (Two-way sync with Web App) ---
  Future<bool> importDatabaseJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = (decoded['data'] as Map<String, dynamic>?) ?? decoded;

      if (data.containsKey('products') && data['products'] is List) {
        _products = (data['products'] as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
        await _db.saveProducts(_products);
      }

      if (data.containsKey('invoices') && data['invoices'] is List) {
        _invoices = (data['invoices'] as List)
            .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
            .toList();
        await _db.saveInvoices(_invoices);
      }

      if (data.containsKey('customers') && data['customers'] is List) {
        _customers = (data['customers'] as List)
            .map((e) => Customer.fromJson(e as Map<String, dynamic>))
            .toList();
        await _db.saveCustomers(_customers);
      }

      if (data.containsKey('payments') && data['payments'] is List) {
        _payments = (data['payments'] as List)
            .map((e) => CustomerPayment.fromJson(e as Map<String, dynamic>))
            .toList();
        await _db.savePayments(_payments);
      }

      if ((data.containsKey('productReturns') && data['productReturns'] is List) ||
          (data.containsKey('returns') && data['returns'] is List)) {
        final rawR = (data['productReturns'] ?? data['returns']) as List;
        _returns = rawR.map((e) => ProductReturn.fromJson(e as Map<String, dynamic>)).toList();
        await _db.saveReturns(_returns);
      }

      if ((data.containsKey('treasuryTransactions') && data['treasuryTransactions'] is List) ||
          (data.containsKey('treasury') && data['treasury'] is List)) {
        final rawT = (data['treasuryTransactions'] ?? data['treasury']) as List;
        _treasury = rawT.map((e) => TreasuryTransaction.fromJson(e as Map<String, dynamic>)).toList();
        await _db.saveTreasury(_treasury);
      }

      if (data.containsKey('settings') && data['settings'] is Map<String, dynamic>) {
        _settings = StoreSettings.fromJson(data['settings'] as Map<String, dynamic>);
        await _db.saveSettings(_settings);
      }

      _addLog(
        title: 'همگام‌سازی و بازیابی دیتابیس',
        description: 'داده‌ها با موفقیت از فایل پشتیبان وب ایمپورت شدند.',
        type: 'backup',
      );
      _createOnChangeSnapshot('همگام‌سازی داده‌ها با فایل وب');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing database: $e');
      return false;
    }
  }

  // Next invoice number
  String getNextInvoiceNumber() {
    if (_invoices.isEmpty) return '1001';
    final numbers = _invoices.map((i) {
      final cleaned = toEnglishDigits(i.invoiceNumber);
      return int.tryParse(cleaned) ?? 0;
    }).toList();
    final maxNum = numbers.fold(1000, (max, cur) => cur > max ? cur : max);
    return (maxNum + 1).toString();
  }
}
