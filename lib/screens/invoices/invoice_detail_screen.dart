import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice.dart';
import '../../providers/app_state.dart';
import '../../services/export_service.dart';
import '../../utils/formatters.dart';
import 'invoice_editor_screen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final GlobalKey _invoicePaperKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Fetch live instance of invoice if updated
    final inv = state.invoices.firstWhere(
      (i) => i.id == widget.invoice.id,
      orElse: () => widget.invoice,
    );
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text('فاکتور شماره ${toPersianDigits(inv.invoiceNumber)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'ویرایش فاکتور',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceEditorScreen(invoiceToEdit: inv),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'حذف فاکتور',
            onPressed: () => _confirmDelete(context, inv),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Share Image Button (WhatsApp / Telegram)
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
                          repaintBoundaryKey: _invoicePaperKey,
                          title: 'فاکتور_${inv.invoiceNumber}_${inv.customerName}',
                          caption: 'فاکتور شماره ${toPersianDigits(inv.invoiceNumber)} - ${inv.customerName}\nمبلغ: ${formatPrice(inv.finalAmount, showUnit: true)}',
                        );
                        setState(() => _isSharing = false);
                      },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('ارسال عکس فاکتور'),
              ),
            ),
            const SizedBox(width: 10),
            // Share PDF Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ExportService.shareInvoicePdf(invoice: inv, settings: settings);
                },
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('PDF'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RepaintBoundary(
              key: _invoicePaperKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300, width: 1),
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
                              Text(settings.subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                              Text('تلفن: ${toPersianDigits(settings.phone)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: inv.type == 'sale' ? Colors.blue.shade50 : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: inv.type == 'sale' ? Colors.blue.shade200 : Colors.amber.shade200,
                                  ),
                                ),
                                child: Text(
                                  inv.type == 'sale' ? 'فاکتور فروش کالا' : 'فاکتور خرید کالا',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: inv.type == 'sale' ? Colors.blue.shade800 : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('شماره: ${toPersianDigits(inv.invoiceNumber)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('تاریخ: ${toPersianDigits(inv.date)} - ${toPersianDigits(inv.time)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFFE2E8F0), thickness: 1),
                      const SizedBox(height: 10),

                      // Customer Info Box
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
                            Text('خریدار: ${inv.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('تلفن: ${toPersianDigits(inv.customerPhone)}', style: const TextStyle(fontSize: 11)),
                            Text('شهر: ${inv.customerCity}', style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Items Table
                      Table(
                        border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 0.8),
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                            children: const [
                              Padding(padding: EdgeInsets.all(6), child: Center(child: Text('ردیف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                              Padding(padding: EdgeInsets.all(6), child: Center(child: Text('شرح کالا', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                              Padding(padding: EdgeInsets.all(6), child: Center(child: Text('کارتن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                              Padding(padding: EdgeInsets.all(6), child: Center(child: Text('دانه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                              Padding(padding: EdgeInsets.all(6), child: Center(child: Text('کل تعداد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                              Padding(padding: EdgeInsets.all(6), child: Center(child: Text('قیمت واحد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                              Padding(padding: EdgeInsets.all(6), child: Center(child: Text('مبلغ کل (تومان)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
                            ],
                          ),
                          ...inv.items.asMap().entries.map((entry) {
                            final idx = entry.key + 1;
                            final it = entry.value;
                            return TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(6), child: Center(child: Text(toPersianDigits(idx), style: const TextStyle(fontSize: 10)))),
                                Padding(padding: const EdgeInsets.all(6), child: Text(it.productName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500))),
                                Padding(padding: const EdgeInsets.all(6), child: Center(child: Text(toPersianDigits(it.cartonsCount), style: const TextStyle(fontSize: 10)))),
                                Padding(padding: const EdgeInsets.all(6), child: Center(child: Text(toPersianDigits(it.extraPieces), style: const TextStyle(fontSize: 10)))),
                                Padding(padding: const EdgeInsets.all(6), child: Center(child: Text(toPersianDigits(it.totalPieces), style: const TextStyle(fontSize: 10)))),
                                Padding(padding: const EdgeInsets.all(6), child: Center(child: Text(formatPrice(it.unitSellingPrice), style: const TextStyle(fontSize: 10)))),
                                Padding(padding: const EdgeInsets.all(6), child: Center(child: Text(formatPrice(it.totalPrice), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
                              ],
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Totals & Bank Account Details
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('روش تسویه: ${inv.paymentMethod}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('شماره کارت: ${toPersianDigits(settings.cardNumber)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                                Text('بانک: ${settings.bankName}', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                                Text('شبا: ${settings.iban}', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                              ],
                            ),
                          ),
                          Container(
                            width: 200,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('جمع اقلام:', style: TextStyle(fontSize: 11)),
                                    Text(formatPrice(inv.subtotal), style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                                if (inv.discount > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('تخفیف:', style: TextStyle(fontSize: 11, color: Colors.red)),
                                      Text(formatPrice(inv.discount), style: const TextStyle(fontSize: 11, color: Colors.red)),
                                    ],
                                  ),
                                ],
                                const Divider(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('مبلغ نهایی:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text('${formatPrice(inv.finalAmount)} تومان', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'مبلغ به حروف: ${numberToPersianWords(inv.finalAmount)}',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                        ),
                      ),

                      // Stamp & Signature Area
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('امضای خریدار / تحویل‌گیرنده: .....................', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Column(
                            children: [
                              Text('مهر و امضای فروشنده: ${settings.sellerStampName}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue.shade700, width: 1.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  settings.sellerStampName,
                                  style: TextStyle(color: Colors.blue.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  void _confirmDelete(BuildContext context, Invoice inv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف فاکتور'),
        content: Text('آیا از حذف کامل فاکتور شماره ${toPersianDigits(inv.invoiceNumber)} اطمینان دارید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AppState>().deleteInvoice(inv.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: const Text('حذف فاکتور'),
          ),
        ],
      ),
    );
  }
}
