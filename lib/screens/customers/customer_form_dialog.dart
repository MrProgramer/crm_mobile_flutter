import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/customer.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';

class CustomerFormDialog extends StatefulWidget {
  final Customer? customer;

  const CustomerFormDialog({super.key, this.customer});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _nationalCodeController;
  late TextEditingController _initialBalanceController;
  late TextEditingController _creditLimitController;
  late TextEditingController _notesController;

  String _customerType = 'regular'; // regular, distributor, supplier, both, partner

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _companyController = TextEditingController(text: c?.company ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _cityController = TextEditingController(text: c?.city ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _nationalCodeController = TextEditingController(text: c?.nationalCode ?? '');
    _initialBalanceController = TextEditingController(
      text: c != null ? c.initialBalance.round().toString() : '0',
    );
    _creditLimitController = TextEditingController(
      text: c?.creditLimit != null ? c!.creditLimit!.round().toString() : '',
    );
    _notesController = TextEditingController(text: c?.notes ?? '');
    _customerType = c?.customerType ?? 'regular';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _nationalCodeController.dispose();
    _initialBalanceController.dispose();
    _creditLimitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: widget.customer?.id ?? 'cust-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 4)}',
      name: _nameController.text.trim(),
      company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
      customerType: _customerType,
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      nationalCode: _nationalCodeController.text.trim().isNotEmpty ? _nationalCodeController.text.trim() : null,
      initialBalance: double.tryParse(toEnglishDigits(_initialBalanceController.text)) ?? 0.0,
      creditLimit: double.tryParse(toEnglishDigits(_creditLimitController.text)),
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: widget.customer?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    final state = context.read<AppState>();
    if (widget.customer == null) {
      state.addCustomer(customer);
    } else {
      state.updateCustomer(customer);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'ویرایش طرف حساب' : 'افزودن طرف حساب جدید',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'نام و نام خانوادگی *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'نام الزامی است' : null,
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _customerType,
                  decoration: const InputDecoration(labelText: 'نوع طرف حساب'),
                  items: const [
                    DropdownMenuItem(value: 'regular', child: Text('مشتری عادی و خریدار خرد')),
                    DropdownMenuItem(value: 'distributor', child: Text('عامل پخش و بنکدار')),
                    DropdownMenuItem(value: 'supplier', child: Text('تأمین‌کننده و شرکت')),
                    DropdownMenuItem(value: 'both', child: Text('دوطرفه (هم خریدار و هم تامین‌کننده)')),
                    DropdownMenuItem(value: 'partner', child: Text('همکار تجاری و ویزیتور')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _customerType = val);
                  },
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'شماره همراه *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'شماره تماس الزامی است' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'شهر / استان'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'نام فروشگاه / شرکت'),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _initialBalanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'مانده اولیه (تومان)',
                          hintText: 'مثبت: بدهکار، منفی: بستانکار',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _creditLimitController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'سقف اعتبار خرید'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'آدرس کامل'),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'یادداشت‌های پرونده طرف حساب'),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(isEdit ? 'ذخیره تغییرات' : 'ثبت نهایی طرف حساب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
