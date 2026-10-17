import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isProcessing = false;

  Future<void> _exportBackupFile(AppState state) async {
    setState(() => _isProcessing = true);
    try {
      final snap = state.generateSnapshotObject(type: 'manual', note: 'خروجی دستی جهت همگام‌سازی با وب');
      final jsonString = const JsonEncoder.withIndent('  ').convert(snap.data);

      final tempDir = await getTemporaryDirectory();
      final date = getCurrentPersianDate().replaceAll('/', '-');
      final time = getCurrentPersianTime().replaceAll(':', '');
      final fileName = 'bazargani-backup-$date-$time-manual.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        text: 'پشتیبان دیتابیس سیستم بازرگانی و انبارداری (سازگار با نسخه تحت وب)',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در اکسپورت دیتابیس: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _importBackupFile(AppState state) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      setState(() => _isProcessing = true);
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString(encoding: utf8);

      final success = await state.importDatabaseJson(jsonString);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('دیتابیس با موفقیت همگام‌سازی و بازیابی گردید.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فایل انتخاب شده معتبر نیست یا ساختار نامعتبر دارد.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری فایل: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('پشتیبان‌گیری و همگام‌سازی با وب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync & Export Banner
            Card(
              color: Colors.blue.shade50.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.sync_alt, size: 40, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      'همگام‌سازی دوطرفه با برنامه تحت وب',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'شما می‌توانید فایل اکسپورت این برنامه را به طور مستقیم در نسخه وب ایمپورت کنید، یا فایل بک‌آپ نسخه وب را در این برنامه فراخوانی نمایید.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _isProcessing ? null : () => _exportBackupFile(state),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('اکسپورت JSON'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _isProcessing ? null : () => _importBackupFile(state),
                            icon: const Icon(Icons.download),
                            label: const Text('ایمپورت فایل وب'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Card
            const Text('خلاصه داده‌های ذخیره شده در حافظه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatRow('تعداد اقلام کالا در انبار', toPersianDigits(state.products.length)),
                    const Divider(height: 16),
                    _buildStatRow('کل اسناد و فاکتورها', toPersianDigits(state.invoices.length)),
                    const Divider(height: 16),
                    _buildStatRow('تعداد پرونده‌های طرف حساب', toPersianDigits(state.customers.length)),
                    const Divider(height: 16),
                    _buildStatRow('تراکنش‌ها و واریزی‌های ثبت شده', toPersianDigits(state.payments.length)),
                    const Divider(height: 16),
                    _buildStatRow('اسناد مرجوعی کالا', toPersianDigits(state.returns.length)),
                    const Divider(height: 16),
                    _buildStatRow('تراکنش‌های خزانه و صندوق', toPersianDigits(state.treasury.length)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Snapshots History
            const Text('تاریخچه نسخه‌های پشتیبان هوشمند', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            if (state.snapshots.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('هنوز نسخه‌ای ذخیره نشده است', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.snapshots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final snap = state.snapshots[idx];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.withOpacity(0.12),
                        child: const Icon(Icons.backup_outlined, color: Colors.teal, size: 20),
                      ),
                      title: Text(snap.changeAction ?? snap.note ?? 'نسخه پشتیبان', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${toPersianDigits(snap.dateFormatted)} - ساعت ${toPersianDigits(snap.timeFormatted)}', style: const TextStyle(fontSize: 11)),
                      trailing: Text(
                        '${toPersianDigits(snap.invoicesCount)} فاکتور',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
