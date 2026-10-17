import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/customer_payment.dart';
import '../models/product_return.dart';
import '../models/store_settings.dart';
import '../utils/formatters.dart';
import '../utils/calculations.dart';

class ExportService {
  /// Captures any widget inside a GlobalKey (RepaintBoundary) as a high-resolution PNG image
  /// and shares it via native Android share sheet (WhatsApp, Telegram, etc.)
  static Future<void> captureAndShareImage({
    required GlobalKey repaintBoundaryKey,
    required String title,
    String? caption,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9_\u0600-\u06FF]'), '_');
      final file = File('${tempDir.path}/$sanitizedTitle.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: caption ?? title,
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  /// Generate and share Invoice as PDF
  static Future<void> shareInvoicePdf({
    required Invoice invoice,
    required StoreSettings settings,
  }) async {
    try {
      final doc = pw.Document();
      final font = await PdfGoogleFonts.vazirmatnRegular();
      final boldFont = await PdfGoogleFonts.vazirmatnBold();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(settings.brandName, style: pw.TextStyle(font: boldFont, fontSize: 18)),
                          pw.Text(settings.subtitle, style: pw.TextStyle(font: font, fontSize: 11)),
                          pw.Text('تلفن: ${toPersianDigits(settings.phone)}', style: pw.TextStyle(font: font, fontSize: 10)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(invoice.type == 'sale' ? 'فاکتور فروش کالا' : 'فاکتور خرید کالا',
                              style: pw.TextStyle(font: boldFont, fontSize: 16)),
                          pw.Text('شماره فاکتور: ${toPersianDigits(invoice.invoiceNumber)}',
                              style: pw.TextStyle(font: font, fontSize: 11)),
                          pw.Text('تاریخ: ${toPersianDigits(invoice.date)}  ساعت: ${toPersianDigits(invoice.time)}',
                              style: pw.TextStyle(font: font, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 14),
                  pw.Divider(thickness: 1),

                  // Customer Details
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('خریدار: ${invoice.customerName}', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                        pw.Text('تلفن: ${toPersianDigits(invoice.customerPhone)}', style: pw.TextStyle(font: font, fontSize: 11)),
                        pw.Text('شهر: ${invoice.customerCity}', style: pw.TextStyle(font: font, fontSize: 11)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 14),

                  // Items Table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('ردیف', style: pw.TextStyle(font: boldFont, fontSize: 10)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('شرح کالا', style: pw.TextStyle(font: boldFont, fontSize: 10)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('کارتن', style: pw.TextStyle(font: boldFont, fontSize: 10)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('دانه', style: pw.TextStyle(font: boldFont, fontSize: 10)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('کل تعداد', style: pw.TextStyle(font: boldFont, fontSize: 10)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('قیمت واحد (تومان)', style: pw.TextStyle(font: boldFont, fontSize: 10)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text('مبلغ کل (تومان)', style: pw.TextStyle(font: boldFont, fontSize: 10)))),
                        ],
                      ),
                      ...invoice.items.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final it = entry.value;
                        return pw.TableRow(
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text(toPersianDigits(idx), style: pw.TextStyle(font: font, fontSize: 9)))),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(it.productName, style: pw.TextStyle(font: font, fontSize: 9))),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text(toPersianDigits(it.cartonsCount), style: pw.TextStyle(font: font, fontSize: 9)))),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text(toPersianDigits(it.extraPieces), style: pw.TextStyle(font: font, fontSize: 9)))),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text(toPersianDigits(it.totalPieces), style: pw.TextStyle(font: font, fontSize: 9)))),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text(formatPrice(it.unitSellingPrice), style: pw.TextStyle(font: font, fontSize: 9)))),
                            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text(formatPrice(it.totalPrice), style: pw.TextStyle(font: font, fontSize: 9)))),
                          ],
                        );
                      }),
                    ],
                  ),
                  pw.SizedBox(height: 16),

                  // Totals
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('روش تسویه: ${invoice.paymentMethod}', style: pw.TextStyle(font: font, fontSize: 11)),
                          pw.Text('شماره کارت: ${toPersianDigits(settings.cardNumber)} (${settings.bankName})',
                              style: pw.TextStyle(font: font, fontSize: 10)),
                          pw.Text('شماره شبا: ${settings.iban}', style: pw.TextStyle(font: font, fontSize: 10)),
                        ],
                      ),
                      pw.Container(
                        width: 200,
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.TableBorder.all(color: PdfColors.grey300),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('جمع اقلام:', style: pw.TextStyle(font: font, fontSize: 10)),
                                pw.Text('${formatPrice(invoice.subtotal)} تومان', style: pw.TextStyle(font: font, fontSize: 10)),
                              ],
                            ),
                            if (invoice.discount > 0)
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('تخفیف:', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.red700)),
                                  pw.Text('${formatPrice(invoice.discount)} تومان', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.red700)),
                                ],
                              ),
                            pw.Divider(thickness: 0.5),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('مبلغ نهایی:', style: pw.TextStyle(font: boldFont, fontSize: 11)),
                                pw.Text('${formatPrice(invoice.finalAmount)} تومان', style: pw.TextStyle(font: boldFont, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text('مبلغ به حروف: ${numberToPersianWords(invoice.finalAmount)}',
                      style: pw.TextStyle(font: font, fontSize: 11)),
                ],
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/فاکتور_${invoice.invoiceNumber}.pdf');
      await file.writeAsBytes(await doc.save());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'فاکتور شماره ${invoice.invoiceNumber} - ${invoice.customerName}',
      );
    } catch (e) {
      debugPrint('Error exporting invoice PDF: $e');
    }
  }

  /// Generate and share Customer Statement / Shot Hesab as PDF
  static Future<void> shareCustomerStatementPdf({
    required Customer customer,
    required List<Invoice> invoices,
    required List<CustomerPayment> payments,
    required List<ProductReturn> returns,
    required StoreSettings settings,
  }) async {
    try {
      final doc = pw.Document();
      final font = await PdfGoogleFonts.vazirmatnRegular();
      final boldFont = await PdfGoogleFonts.vazirmatnBold();

      final custInvoices = getCustomerSalesInvoices(customer, invoices);
      final custPayments = getCustomerPayments(customer, payments);
      final balance = calculateCustomerLiveBalance(customer, invoices, payments, returns);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(settings.brandName, style: pw.TextStyle(font: boldFont, fontSize: 18)),
                          pw.Text('صورت‌حساب و کاردکس مالی مشتری', style: pw.TextStyle(font: font, fontSize: 12)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('تاریخ گزارش: ${toPersianDigits(getCurrentPersianDate())}',
                              style: pw.TextStyle(font: font, fontSize: 11)),
                          pw.Text('ساعت: ${toPersianDigits(getCurrentPersianTime())}',
                              style: pw.TextStyle(font: font, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 14),
                  pw.Divider(thickness: 1),

                  // Customer Box
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('طرف حساب: ${customer.name}', style: pw.TextStyle(font: boldFont, fontSize: 13)),
                        pw.Text('تلفن: ${toPersianDigits(customer.phone)}', style: pw.TextStyle(font: font, fontSize: 11)),
                        pw.Text('شهر: ${customer.city}', style: pw.TextStyle(font: font, fontSize: 11)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Invoices Summary
                  pw.Text('فاکتورهای اخیر:', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  pw.SizedBox(height: 6),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text('شماره فاکتور', style: pw.TextStyle(font: boldFont, fontSize: 9)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text('تاریخ', style: pw.TextStyle(font: boldFont, fontSize: 9)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text('نوع تسویه', style: pw.TextStyle(font: boldFont, fontSize: 9)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text('مبلغ فاکتور (تومان)', style: pw.TextStyle(font: boldFont, fontSize: 9)))),
                        ],
                      ),
                      ...custInvoices.take(10).map((inv) => pw.TableRow(
                            children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(toPersianDigits(inv.invoiceNumber), style: pw.TextStyle(font: font, fontSize: 9)))),
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(toPersianDigits(inv.date), style: pw.TextStyle(font: font, fontSize: 9)))),
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(inv.paymentMethod, style: pw.TextStyle(font: font, fontSize: 9)))),
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(formatPrice(inv.finalAmount), style: pw.TextStyle(font: font, fontSize: 9)))),
                            ],
                          )),
                    ],
                  ),
                  pw.SizedBox(height: 16),

                  // Payments Summary
                  pw.Text('واریزی‌ها و پرداختی‌ها:', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  pw.SizedBox(height: 6),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text('تاریخ', style: pw.TextStyle(font: boldFont, fontSize: 9)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text('روش پرداخت', style: pw.TextStyle(font: boldFont, fontSize: 9)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text('شماره پیگیری', style: pw.TextStyle(font: boldFont, fontSize: 9)))),
                          pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text('مبلغ (تومان)', style: pw.TextStyle(font: boldFont, fontSize: 9)))),
                        ],
                      ),
                      ...custPayments.take(10).map((p) => pw.TableRow(
                            children: [
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(toPersianDigits(p.date), style: pw.TextStyle(font: font, fontSize: 9)))),
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(p.paymentMethod == 'card' ? 'کارت به کارت' : 'واریز بانکی', style: pw.TextStyle(font: font, fontSize: 9)))),
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(toPersianDigits(p.referenceNumber ?? '-'), style: pw.TextStyle(font: font, fontSize: 9)))),
                              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(formatPrice(p.amount), style: pw.TextStyle(font: font, fontSize: 9)))),
                            ],
                          )),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Final Balance
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: balance > 0 ? PdfColors.red50 : (balance < 0 ? PdfColors.green50 : PdfColors.blue50),
                      border: pw.TableBorder.all(
                        color: balance > 0 ? PdfColors.red300 : (balance < 0 ? PdfColors.green300 : PdfColors.blue300),
                      ),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          balance > 0
                              ? 'مانده بدهی نهایی مشتری:'
                              : (balance < 0 ? 'مانده بستانکاری مشتری:' : 'وضعیت حساب:'),
                          style: pw.TextStyle(font: boldFont, fontSize: 13),
                        ),
                        pw.Text(
                          balance == 0
                              ? 'تسویه شده / بی‌حساب'
                              : '${formatPrice(balance.abs())} تومان',
                          style: pw.TextStyle(font: boldFont, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (balance != 0) ...[
                    pw.SizedBox(height: 8),
                    pw.Text('مبلغ به حروف: ${numberToPersianWords(balance.abs())}',
                        style: pw.TextStyle(font: font, fontSize: 11)),
                  ],
                ],
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/صورت‌حساب_${customer.name}.pdf');
      await file.writeAsBytes(await doc.save());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        text: 'صورت‌حساب و شات حساب طرف حساب ${customer.name}',
      );
    } catch (e) {
      debugPrint('Error exporting statement PDF: $e');
    }
  }
}
