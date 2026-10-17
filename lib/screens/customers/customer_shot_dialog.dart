import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/app_state.dart';
import '../../services/export_service.dart';
import '../../utils/formatters.dart';
import '../../utils/calculations.dart';

class CustomerShotDialog extends StatefulWidget {
  final Customer customer;

  const CustomerShotDialog({super.key, required this.customer});

  @override
  State<CustomerShotDialog> createState() => _CustomerShotDialogState();
}

class _CustomerShotDialogState extends State<CustomerShotDialog> {
  final GlobalKey _shotCardKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final customer = widget.customer;
    final settings = state.settings;

    final balance = calculateCustomerLiveBalance(customer, state.invoices, state.payments, state.returns);
    final custInvoices = getCustomerSalesInvoices(customer, state.invoices);
    final custPayments = getCustomerPayments(customer, state.payments);

    final isDebtor = balance > 0;
    final isCreditor = balance < 0;
    final isSettled = balance == 0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Modal Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'شات رسمی وضعیت حساب مشتری',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Shot Card Area
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: RepaintBoundary(
                  key: _shotCardKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade300, width: 1.2),
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Color(0xFF0F172A), fontFamily: 'Vazirmatn'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    settings.brandName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'برگه گزارش وضعیت و شات مانده حساب',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'تاریخ: ${toPersianDigits(getCurrentPersianDate())}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                  ),
                                  Text(
                                    'ساعت: ${toPersianDigits(getCurrentPersianTime())}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFE2E8F0), thickness: 1),
                          const SizedBox(height: 10),

                          // Customer Profile
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('طرف حساب: ${customer.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    if (customer.company != null && customer.company!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text('فروشگاه: ${customer.company}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                                    ],
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('تلفن: ${toPersianDigits(customer.phone)}', style: const TextStyle(fontSize: 11)),
                                    Text('شهر: ${customer.city}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Prominent Balance Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDebtor
                                  ? Colors.red.shade50
                                  : (isCreditor ? Colors.green.shade50 : Colors.blue.shade50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDebtor
                                    ? Colors.red.shade300
                                    : (isCreditor ? Colors.green.shade300 : Colors.blue.shade300),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  isDebtor
                                      ? 'مانده بدهی نهایی طرف حساب'
                                      : (isCreditor ? 'مانده بستانکاری طرف حساب' : 'وضعیت حساب'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDebtor
                                        ? Colors.red.shade900
                                        : (isCreditor ? Colors.green.shade900 : Colors.blue.shade900),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isSettled ? 'تسویه شده / بی‌حساب' : '${formatPrice(balance.abs())} تومان',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDebtor
                                        ? Colors.red.shade800
                                        : (isCreditor ? Colors.green.shade800 : Colors.blue.shade800),
                                  ),
                                ),
                                if (!isSettled) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    numberToPersianWords(balance.abs()),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDebtor ? Colors.red.shade700 : Colors.green.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Recent Invoices mini table
                          if (custInvoices.isNotEmpty) ...[
                            const Text('فاکتورهای اخیر:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            Table(
                              border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 0.6),
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                  children: const [
                                    Padding(padding: EdgeInsets.all(5), child: Center(child: Text('شماره', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                                    Padding(padding: EdgeInsets.all(5), child: Center(child: Text('تاریخ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                                    Padding(padding: EdgeInsets.all(5), child: Center(child: Text('تسویه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                                    Padding(padding: EdgeInsets.all(5), child: Center(child: Text('مبلغ فاکتور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                                  ],
                                ),
                                ...custInvoices.take(4).map((inv) => TableRow(
                                      children: [
                                        Padding(padding: const EdgeInsets.all(5), child: Center(child: Text(toPersianDigits(inv.invoiceNumber), style: const TextStyle(fontSize: 10)))),
                                        Padding(padding: const EdgeInsets.all(5), child: Center(child: Text(toPersianDigits(inv.date), style: const TextStyle(fontSize: 10)))),
                                        Padding(padding: const EdgeInsets.all(5), child: Center(child: Text(inv.paymentMethod, style: const TextStyle(fontSize: 10)))),
                                        Padding(padding: const EdgeInsets.all(5), child: Center(child: Text(formatPrice(inv.finalAmount), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                                      ],
                                    )),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Recent Payments mini table
                          if (custPayments.isNotEmpty) ...[
                            const Text('واریزی‌های اخیر:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            Table(
                              border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 0.6),
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                  children: const [
                                    Padding(padding: EdgeInsets.all(5), child: Center(child: Text('تاریخ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                                    Padding(padding: EdgeInsets.all(5), child: Center(child: Text('روش', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                                    Padding(padding: EdgeInsets.all(5), child: Center(child: Text('پیگیری', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                                    Padding(padding: EdgeInsets.all(5), child: Center(child: Text('مبلغ (تومان)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                                  ],
                                ),
                                ...custPayments.take(3).map((p) => TableRow(
                                      children: [
                                        Padding(padding: const EdgeInsets.all(5), child: Center(child: Text(toPersianDigits(p.date), style: const TextStyle(fontSize: 10)))),
                                        Padding(padding: const EdgeInsets.all(5), child: Center(child: Text(p.paymentMethod == 'card' ? 'کارت به کارت' : 'واریز', style: const TextStyle(fontSize: 10)))),
                                        Padding(padding: const EdgeInsets.all(5), child: Center(child: Text(toPersianDigits(p.referenceNumber ?? '-'), style: const TextStyle(fontSize: 10)))),
                                        Padding(padding: const EdgeInsets.all(5), child: Center(child: Text(formatPrice(p.amount), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)))),
                                      ],
                                    )),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Payment Bank Account Details
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('جهت واریز و تسویه حساب:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text('شماره کارت: ${toPersianDigits(settings.cardNumber)} (${settings.bankName})', style: const TextStyle(fontSize: 11)),
                                Text('شماره شبا: ${settings.iban}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Stamp & signature
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('تلفن تماس: ${toPersianDigits(settings.phone)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue.shade700, width: 1.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  settings.sellerStampName,
                                  style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Actions Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isSharing
                          ? null
                          : () async {
                              setState(() => _isSharing = true);
                              await ExportService.captureAndShareImage(
                                repaintBoundaryKey: _shotCardKey,
                                title: 'شات_حساب_${customer.name}',
                                caption: 'شات وضعیت حساب ${customer.name}\nمانده حساب: ${formatPrice(balance.abs(), showUnit: true)}',
                              );
                              setState(() => _isSharing = false);
                            },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('ارسال عکس به مشتری (واتساپ)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ExportService.shareCustomerStatementPdf(
                          customer: customer,
                          invoices: state.invoices,
                          payments: state.payments,
                          returns: state.returns,
                          settings: settings,
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('PDF'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
