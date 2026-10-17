import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import '../../utils/calculations.dart';
import '../../theme/app_theme.dart';
import 'customer_shot_dialog.dart';
import 'payment_form_dialog.dart';
import 'customer_form_dialog.dart';
import '../invoices/invoice_editor_screen.dart';
import '../invoices/invoice_detail_screen.dart';

class CustomerStatementScreen extends StatefulWidget {
  final Customer customer;

  const CustomerStatementScreen({super.key, required this.customer});

  @override
  State<CustomerStatementScreen> createState() => _CustomerStatementScreenState();
}

class _CustomerStatementScreenState extends State<CustomerStatementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final customer = state.customers.firstWhere(
      (c) => c.id == widget.customer.id,
      orElse: () => widget.customer,
    );

    final balance = calculateCustomerLiveBalance(customer, state.invoices, state.payments, state.returns);
    final custInvoices = getCustomerSalesInvoices(customer, state.invoices);
    final custPayments = getCustomerPayments(customer, state.payments);

    final isDebtor = balance > 0;
    final isCreditor = balance < 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('کاردکس مالی: ${customer.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'ویرایش پرونده',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CustomerFormDialog(customer: customer),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.blue),
            tooltip: 'شات حساب مشتری',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CustomerShotDialog(customer: customer),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDebtor
                  ? Colors.red.shade50
                  : (isCreditor ? Colors.green.shade50 : Colors.blue.shade50),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          '${customer.phone} - ${customer.city}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isDebtor ? 'مانده بدهی:' : (isCreditor ? 'مانده بستانکاری:' : 'وضعیت:'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDebtor ? Colors.red.shade900 : (isCreditor ? Colors.green.shade900 : Colors.blue.shade900),
                          ),
                        ),
                        Text(
                          balance == 0 ? 'تسویه شده' : '${formatPrice(balance.abs())} تومان',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDebtor ? Colors.red.shade800 : (isCreditor ? Colors.green.shade800 : Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => CustomerShotDialog(customer: customer),
                          );
                        },
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('شات حساب (عکس)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PaymentFormDialog(customer: customer),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('ثبت واریزی'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'دفتر معین (${toPersianDigits(custInvoices.length + custPayments.length)})'),
              Tab(text: 'فاکتورها (${toPersianDigits(custInvoices.length)})'),
              Tab(text: 'واریزی‌ها (${toPersianDigits(custPayments.length)})'),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Ledger view (Combined chronological list)
                _buildLedgerView(custInvoices, custPayments),

                // Invoices view
                _buildInvoicesView(custInvoices),

                // Payments view
                _buildPaymentsView(custPayments, state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceEditorScreen(
                isPurchase: false,
                preselectedCustomer: customer,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('فاکتور جدید برای این مشتری'),
      ),
    );
  }

  Widget _buildLedgerView(List<dynamic> invoices, List<dynamic> payments) {
    final List<Map<String, dynamic>> entries = [];

    for (final inv in invoices) {
      entries.add({
        'type': 'invoice',
        'date': inv.date,
        'title': 'فاکتور شماره ${toPersianDigits(inv.invoiceNumber)}',
        'subtitle': inv.paymentMethod,
        'amount': inv.finalAmount,
        'isDebit': true, // بدهکار شد
        'raw': inv,
      });
    }

    for (final pay in payments) {
      entries.add({
        'type': 'payment',
        'date': pay.date,
        'title': pay.paymentMethod == 'card' ? 'واریز کارت به کارت' : 'واریز بانکی',
        'subtitle': pay.referenceNumber != null ? 'پیگیری: ${toPersianDigits(pay.referenceNumber)}' : (pay.description ?? ''),
        'amount': pay.amount,
        'isDebit': false, // بستانکار شد / طلب ما کم شد
        'raw': pay,
      });
    }

    if (entries.isEmpty) {
      return const Center(child: Text('هیچ رویداد مالی ثبت نشده است', style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final e = entries[idx];
        final isDebit = e['isDebit'] as bool;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDebit ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12),
              child: Icon(
                isDebit ? Icons.receipt_long : Icons.payments,
                color: isDebit ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            title: Text(e['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('${toPersianDigits(e['date'])} - ${e['subtitle']}', style: const TextStyle(fontSize: 11)),
            trailing: Text(
              '${isDebit ? '+' : '-'}${formatPrice(e['amount'] as num, showUnit: true)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDebit ? Colors.red.shade800 : Colors.green.shade800,
              ),
            ),
            onTap: e['type'] == 'invoice'
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoiceDetailScreen(invoice: e['raw']),
                      ),
                    );
                  }
                : null,
          ),
        );
      },
    );
  }

  Widget _buildInvoicesView(List<dynamic> invoices) {
    if (invoices.isEmpty) {
      return const Center(child: Text('فاکتوری برای این طرف حساب ثبت نشده است', style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final inv = invoices[idx];
        return Card(
          child: ListTile(
            title: Text('فاکتور شماره ${toPersianDigits(inv.invoiceNumber)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${toPersianDigits(inv.date)} - ${inv.paymentMethod}'),
            trailing: Text(formatPrice(inv.finalAmount, showUnit: true), style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoice: inv)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentsView(List<dynamic> payments, AppState state) {
    if (payments.isEmpty) {
      return const Center(child: Text('هیچ واریزی برای این مشتری ثبت نشده است', style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final p = payments[idx];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.arrow_downward, color: Colors.white, size: 18),
            ),
            title: Text(formatPrice(p.amount, showUnit: true), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            subtitle: Text('${toPersianDigits(p.date)} - ${p.description ?? ''}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () {
                state.deletePayment(p.id);
              },
            ),
          ),
        );
      },
    );
  }
}
