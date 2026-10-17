import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/customer.dart';
import '../../models/customer_payment.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';

class PaymentFormDialog extends StatefulWidget {
  final Customer customer;
  final CustomerPayment? paymentToEdit;

  const PaymentFormDialog({
    super.key,
    required this.customer,
    this.paymentToEdit,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _refController;
  late TextEditingController _descController;
  String _paymentMethod = 'card'; // card, bank_transfer, cash, check

  @override
  void initState() {
    super.initState();
    final p = widget.paymentToEdit;
    _amountController = TextEditingController(text: p != null ? p.amount.round().toString() : '');
    _dateController = TextEditingController(text: p?.date ?? getCurrentPersianDate());
    _refController = TextEditingController(text: p?.referenceNumber ?? '');
    _descController = TextEditingController(text: p?.description ?? 'واریزی بابت تسویه حساب');
    _paymentMethod = p?.paymentMethod ?? 'card';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _refController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(toEnglishDigits(_amountController.text)) ?? 0.0;
    if (amount <= 0) return;

    final payment = CustomerPayment(
      id: widget.paymentToEdit?.id ?? 'pay-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 4)}',
      customerId: widget.customer.id,
      customerName: widget.customer.name,
      amount: amount,
      date: _dateController.text.trim(),
      time: getCurrentPersianTime(),
      paymentMethod: _paymentMethod,
      referenceNumber: _refController.text.trim().isNotEmpty ? _refController.text.trim() : null,
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      createdAt: widget.paymentToEdit?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    context.read<AppState>().addPayment(payment);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('واریزی مبلغ ${formatPrice(amount, showUnit: true)} با موفقیت ثبت شد.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ثبت دریافتی و واریزی مشتری',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              Text(
                'طرف حساب: ${widget.customer.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'مبلغ واریزی (تومان) *',
                  hintText: 'مثلا ۲,۵۰۰,۰۰۰',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'مبلغ الزامی است' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'روش پرداخت'),
                items: const [
                  DropdownMenuItem(value: 'card', child: Text('کارت به کارت')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('واریز بانکی / پایا / ساتنا')),
                  DropdownMenuItem(value: 'cash', child: Text('نقدی / واریز به صندوق')),
                  DropdownMenuItem(value: 'check', child: Text('چک بانکی')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(labelText: 'تاریخ'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _refController,
                      decoration: const InputDecoration(labelText: 'شماره پیگیری / فیش'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'بابت / توضیحات'),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('ثبت نهایی تراکنش مالی'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
