import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/treasury_transaction.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import '../../utils/calculations.dart';

class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final liquidity = calculateLiquidity(
      products: state.products,
      invoices: state.invoices,
      customers: state.customers,
      payments: state.payments,
      returns: state.returns,
      treasury: state.treasury,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('صندوق، بانک و نقدینگی'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balances Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('موجودی دخل و صندوق نقد:', style: TextStyle(fontSize: 13)),
                        Text(formatPrice(liquidity.cashboxBalance, showUnit: true), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('موجودی حساب‌های بانکی:', style: TextStyle(fontSize: 13)),
                        Text(formatPrice(liquidity.bankBalance, showUnit: true), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('کل نقدینگی در دسترس:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(formatPrice(liquidity.totalLiquidity, showUnit: true), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Transactions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('تراکنش‌ها و هزینه‌های انبار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                TextButton.icon(
                  onPressed: () => _openAddTransactionDialog(context, state),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('ثبت هزینه / انتقال'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (state.treasury.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('هیچ سند هزینه‌ای ثبت نشده است', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.treasury.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final t = state.treasury[idx];
                  final isExpense = t.type == 'expense';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isExpense ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                        child: Icon(
                          isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isExpense ? Colors.red : Colors.green,
                          size: 18,
                        ),
                      ),
                      title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(
                        '${toPersianDigits(t.date)} - دسته‌بندی: ${t.category} (${t.source == 'cash' ? 'صندوق نقد' : 'حساب بانکی'})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Text(
                        formatPrice(t.amount, showUnit: true),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isExpense ? Colors.red.shade800 : Colors.green.shade800,
                        ),
                      ),
                      onLongPress: () => state.deleteTreasuryTransaction(t.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openAddTransactionDialog(BuildContext context, AppState state) {
    String type = 'expense';
    String source = 'cash';
    final amountController = TextEditingController();
    final descController = TextEditingController();
    final categoryController = TextEditingController(text: 'اجاره و قبوض');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('ثبت هزینه یا تراکنش خزانه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'expense', label: Text('هزینه')),
                        ButtonSegment(value: 'deposit', label: Text('واریز سرمایه')),
                      ],
                      selected: {type},
                      onSelectionChanged: (val) => setState(() => type = val.first),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'مبلغ به تومان *'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: source,
                      decoration: const InputDecoration(labelText: 'محل پرداخت'),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('صندوق نقدینگی دخل')),
                        DropdownMenuItem(value: 'bank', child: Text('حساب بانکی / کارت')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => source = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'شرح هزینه / بابت'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final amt = double.tryParse(toEnglishDigits(amountController.text)) ?? 0.0;
                          if (amt <= 0) return;

                          final tx = TreasuryTransaction(
                            id: 'tx-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 4)}',
                            type: type,
                            source: source,
                            amount: amt,
                            date: getCurrentPersianDate(),
                            time: getCurrentPersianTime(),
                            description: descController.text.trim().isNotEmpty ? descController.text.trim() : 'هزینه عمومی انبار',
                            category: categoryController.text.trim(),
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                          );

                          state.addTreasuryTransaction(tx);
                          Navigator.pop(ctx);
                        },
                        child: const Text('ثبت نهایی تراکنش'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
