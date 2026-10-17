import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/customer_payment.dart';
import '../models/product_return.dart';
import '../models/treasury_transaction.dart';
import '../models/product.dart';

/// Calculates exact unpaid debt portion from a single sale invoice.
double getInvoiceCreditDebtAmount(Invoice inv) {
  if (inv.isDraft || inv.type != 'sale') return 0.0;

  final finalAmt = inv.finalAmount;
  if (finalAmt <= 0) return 0.0;

  if (inv.paymentStatus == 'cash' ||
      (inv.paymentMethod.contains('نقدی') &&
          !inv.paymentMethod.contains('نسیه') &&
          !inv.paymentMethod.contains('غیر') &&
          inv.paymentStatus == null &&
          (inv.paidAmount == null || inv.paidAmount! >= finalAmt))) {
    return 0.0;
  }

  if (inv.paymentStatus == 'partial' || (inv.paidAmount != null && inv.paidAmount! > 0)) {
    if (inv.remainingAmount != null && inv.remainingAmount! >= 0) {
      return inv.remainingAmount!;
    }
    return (finalAmt - (inv.paidAmount ?? 0)).clamp(0.0, double.infinity);
  }

  return finalAmt;
}

List<Invoice> getCustomerSalesInvoices(Customer customer, List<Invoice> invoices) {
  final custName = customer.name.trim().toLowerCase();
  final custPhone = customer.phone.trim();

  return invoices.where((inv) {
    if (inv.isDraft || inv.type != 'sale') return false;
    if (inv.customerId != null && inv.customerId == customer.id) return true;
    if (custName.isNotEmpty && inv.customerName.trim().toLowerCase() == custName) return true;
    if (custPhone.isNotEmpty && inv.customerPhone.trim() == custPhone) return true;
    return false;
  }).toList();
}

List<Invoice> getCustomerPurchaseInvoices(Customer customer, List<Invoice> invoices) {
  final custName = customer.name.trim().toLowerCase();
  final custPhone = customer.phone.trim();

  return invoices.where((inv) {
    if (inv.isDraft || inv.type != 'purchase') return false;
    if (inv.customerId != null && inv.customerId == customer.id) return true;
    if (custName.isNotEmpty && inv.customerName.trim().toLowerCase() == custName) return true;
    if (custPhone.isNotEmpty && inv.customerPhone.trim() == custPhone) return true;
    return false;
  }).toList();
}

double getCustomerCreditSalesTotal(Customer customer, List<Invoice> invoices) {
  final custInvoices = getCustomerSalesInvoices(customer, invoices);
  return custInvoices.fold(0.0, (sum, inv) => sum + getInvoiceCreditDebtAmount(inv));
}

double getCustomerCreditPurchasesTotal(Customer customer, List<Invoice> invoices) {
  final purchaseInvoices = getCustomerPurchaseInvoices(customer, invoices);
  return purchaseInvoices.fold(0.0, (sum, inv) {
    final finalAmt = inv.finalAmount;
    if (finalAmt <= 0) return sum;
    if (inv.paymentStatus == 'cash') return sum;
    if (inv.paymentStatus == 'partial' || (inv.paidAmount != null && inv.paidAmount! > 0)) {
      final rem = inv.remainingAmount ?? (finalAmt - (inv.paidAmount ?? 0));
      return sum + rem.clamp(0.0, double.infinity);
    }
    return sum + finalAmt;
  });
}

List<CustomerPayment> getCustomerPayments(Customer customer, List<CustomerPayment> payments) {
  final custName = customer.name.trim().toLowerCase();
  return payments.where((p) {
    if (p.customerId == customer.id) return true;
    if (custName.isNotEmpty && p.customerName.trim().toLowerCase() == custName) return true;
    return false;
  }).toList();
}

/// Computes live real-time financial balance for a customer.
/// Positive: Customer owes money (بدهکار است)
/// Negative: We owe customer (بستانکار است)
/// Zero: Settled (بی‌حساب و تسویه)
double calculateCustomerLiveBalance(
  Customer customer,
  List<Invoice> invoices,
  List<CustomerPayment> payments,
  List<ProductReturn> productReturns,
) {
  // 1. Initial balance
  double balance = customer.initialBalance;

  // 2. Unsettled sales invoices debt
  final creditSalesDebt = getCustomerCreditSalesTotal(customer, invoices);
  balance += creditSalesDebt;

  // 3. Purchase debt to supplier (reduces customer's debt or increases our liability)
  final creditPurchasesDebt = getCustomerCreditPurchasesTotal(customer, invoices);
  balance -= creditPurchasesDebt;

  // 4. Payments
  final custPayments = getCustomerPayments(customer, payments);
  for (final p in custPayments) {
    balance -= p.amount; // Positive payment reduces customer debt
  }

  // 5. Product returns from customer (reduces customer's debt)
  final custReturns = productReturns.where((r) {
    if (r.customerId != customer.id && r.customerName.trim().toLowerCase() != customer.name.trim().toLowerCase()) {
      return false;
    }
    return r.type == 'from_customer' && (r.isRefunded != true);
  });
  for (final ret in custReturns) {
    balance -= ret.calculatedNetAmount;
  }

  // 6. Product returns to supplier (reduces our debt to supplier, so increases customer balance towards us)
  final supplierReturns = productReturns.where((r) {
    if (r.customerId != customer.id && r.customerName.trim().toLowerCase() != customer.name.trim().toLowerCase()) {
      return false;
    }
    return r.type == 'to_supplier' && (r.isRefunded != true);
  });
  for (final ret in supplierReturns) {
    balance += ret.calculatedNetAmount;
  }

  return balance;
}

class LiquidityOverview {
  final double cashboxBalance;
  final double bankBalance;
  final double totalLiquidity;
  final double inventoryCostValue;
  final double inventorySellingValue;
  final double totalReceivables; // طلب‌ها از مشتریان
  final double totalPayables; // بدهی‌ها به تامین‌کنندگان
  final double netCapital; // سرمایه خالص

  LiquidityOverview({
    required this.cashboxBalance,
    required this.bankBalance,
    required this.totalLiquidity,
    required this.inventoryCostValue,
    required this.inventorySellingValue,
    required this.totalReceivables,
    required this.totalPayables,
    required this.netCapital,
  });
}

LiquidityOverview calculateLiquidity({
  required List<Product> products,
  required List<Invoice> invoices,
  required List<Customer> customers,
  required List<CustomerPayment> payments,
  required List<ProductReturn> returns,
  required List<TreasuryTransaction> treasury,
}) {
  double cash = 0.0;
  double bank = 0.0;

  // 1. Process invoices cash/bank income
  for (final inv in invoices.where((i) => !i.isDraft)) {
    if (inv.type == 'sale') {
      final amountPaid = (inv.paymentStatus == 'cash'
              ? inv.finalAmount
              : (inv.paidAmount ?? (inv.paymentStatus == 'credit' ? 0.0 : inv.finalAmount)))
          .toDouble();
      if (inv.paymentAccount == 'bank') {
        bank += amountPaid;
      } else {
        cash += amountPaid;
      }
    } else if (inv.type == 'purchase') {
      final amountPaid = (inv.paymentStatus == 'cash'
              ? inv.finalAmount
              : (inv.paidAmount ?? 0.0))
          .toDouble();
      if (inv.paymentAccount == 'bank') {
        bank -= amountPaid;
      } else {
        cash -= amountPaid;
      }
    }
  }

  // 2. Process customer payments
  for (final p in payments) {
    if (p.paymentMethod == 'cash') {
      cash += p.amount;
    } else {
      bank += p.amount;
    }
  }

  // 3. Process treasury transactions
  for (final t in treasury) {
    if (t.type == 'expense') {
      if (t.source == 'cash') cash -= t.amount;
      if (t.source == 'bank') bank -= t.amount;
    } else if (t.type == 'deposit') {
      if (t.source == 'cash') cash += t.amount;
      if (t.source == 'bank') bank += t.amount;
    } else if (t.type == 'transfer') {
      if (t.source == 'cash') cash -= t.amount;
      if (t.source == 'bank') bank -= t.amount;
      if (t.destination == 'cash') cash += t.amount;
      if (t.destination == 'bank') bank += t.amount;
    }
  }

  // 4. Inventory Valuation
  double invCost = 0.0;
  double invSale = 0.0;
  for (final p in products) {
    invCost += p.stockPieces * p.purchasePrice;
    invSale += p.stockPieces * p.sellingPrice;
  }

  // 5. Total Receivables and Payables
  double receivables = 0.0;
  double payables = 0.0;
  for (final c in customers) {
    final bal = calculateCustomerLiveBalance(c, invoices, payments, returns);
    if (bal > 0) receivables += bal;
    if (bal < 0) payables += bal.abs();
  }

  final totalLiq = cash + bank;
  final netCap = totalLiq + invCost + receivables - payables;

  return LiquidityOverview(
    cashboxBalance: cash,
    bankBalance: bank,
    totalLiquidity: totalLiq,
    inventoryCostValue: invCost,
    inventorySellingValue: invSale,
    totalReceivables: receivables,
    totalPayables: payables,
    netCapital: netCap,
  );
}
