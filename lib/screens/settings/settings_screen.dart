import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandNameController;
  late TextEditingController _subtitleController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bankNameController;
  late TextEditingController _cardNumberController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ibanController;
  late TextEditingController _stampNameController;
  late TextEditingController _adminPinController;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>().settings;
    _brandNameController = TextEditingController(text: s.brandName);
    _subtitleController = TextEditingController(text: s.subtitle);
    _phoneController = TextEditingController(text: s.phone);
    _addressController = TextEditingController(text: s.address);
    _bankNameController = TextEditingController(text: s.bankName);
    _cardNumberController = TextEditingController(text: s.cardNumber);
    _accountNumberController = TextEditingController(text: s.accountNumber);
    _ibanController = TextEditingController(text: s.iban);
    _stampNameController = TextEditingController(text: s.sellerStampName);
    _adminPinController = TextEditingController(text: s.adminPin ?? '1234');
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _subtitleController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bankNameController.dispose();
    _cardNumberController.dispose();
    _accountNumberController.dispose();
    _ibanController.dispose();
    _stampNameController.dispose();
    _adminPinController.dispose();
    super.dispose();
  }

  void _save() {
    final state = context.read<AppState>();
    final updated = state.settings.copyWith(
      brandName: _brandNameController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      bankName: _bankNameController.text.trim(),
      cardNumber: _cardNumberController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      iban: _ibanController.text.trim(),
      sellerStampName: _stampNameController.text.trim(),
      adminPin: _adminPinController.text.trim(),
    );

    state.updateSettings(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تنظیمات با موفقیت ذخیره شدند.'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات سامانه و فروشگاه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme and appearance
              const Text('رنگ تم و ظاهر برنامه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('حالت شب (Dark Mode)'),
                        value: state.isDarkMode,
                        onChanged: (_) => state.toggleDarkMode(),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('حالت محرمانه (Secret Mode)'),
                        subtitle: const Text('پنهان‌سازی قیمت خرید و حاشیه سود مقابل مشتری'),
                        value: state.isSecretMode,
                        onChanged: (_) => state.toggleSecretMode(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Store Identity
              const Text('مشخصات برند و سربرگ فاکتور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _brandNameController,
                        decoration: const InputDecoration(labelText: 'نام برند / فروشگاه'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _subtitleController,
                        decoration: const InputDecoration(labelText: 'شعار / زیرنویس سربرگ'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'شماره تلفن بازرگانی'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'آدرس دفتر و انبار مرکزی'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stampNameController,
                        decoration: const InputDecoration(labelText: 'عنوان مهر و امضا'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bank info
              const Text('مشخصات بانکی جهت درج روی فاکتور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _bankNameController,
                        decoration: const InputDecoration(labelText: 'نام بانک'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(labelText: 'شماره کارت'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _accountNumberController,
                        decoration: const InputDecoration(labelText: 'شماره حساب'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _ibanController,
                        decoration: const InputDecoration(labelText: 'شماره شبا (IBAN)'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('ذخیره تغییرات تنظیمات'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
