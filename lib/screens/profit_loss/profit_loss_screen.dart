import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';

class ProfitLossScreen extends StatelessWidget {
  const ProfitLossScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Sales invoices (exclude drafts)
    final sales = state.invoices.where((i) => !i.isDraft && i.type == 'sale').toList();

    double totalGrossSales = 0.0;
    double totalCostOfGoodsSold = 0.0;
    double totalDiscounts = 0.0;

    for (final inv in sales) {
      totalGrossSales += inv.subtotal;
      totalDiscounts += inv.discount;
      totalCostOfGoodsSold += inv.totalPurchaseCost;
    }

    final netSales = totalGrossSales - totalDiscounts;
    final grossProfit = netSales - totalCostOfGoodsSold;

    // Expenses
    double totalExpenses = 0.0;
    for (final t in state.treasury.where((tx) => tx.type == 'expense')) {
      totalExpenses += t.amount;
    }

    final netProfit = grossProfit - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('صورت سود و زیان بازرگانی'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Net Profit Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: netProfit >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    netProfit >= 0 ? 'سود خالص بازرگانی (پس از کسر هزینه‌ها)' : 'زیان خالص بازرگانی',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: netProfit >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isSecretMode ? '*** محرمانه ***' : '${formatPrice(netProfit.abs())} تومان',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: netProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                  if (!state.isSecretMode) ...[
                    const SizedBox(height: 4),
                    Text(
                      numberToPersianWords(netProfit.abs()),
                      style: TextStyle(fontSize: 11, color: netProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Detailed Breakdown Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRow('فروش ناخالص کل (جمع اقلام فاکتورها):', formatPrice(totalGrossSales, showUnit: true)),
                    const Divider(height: 16),
                    _buildRow('تخفیفات اعطایی به مشتریان:', formatPrice(totalDiscounts, showUnit: true), color: Colors.red),
                    const Divider(height: 16),
                    _buildRow('فروش خالص:', formatPrice(netSales, showUnit: true), isBold: true),
                    const Divider(height: 16),
                    _buildRow(
                      'بهای تمام شده کالای فروش رفته (خرید):',
                      state.isSecretMode ? 'محرمانه' : formatPrice(totalCostOfGoodsSold, showUnit: true),
                      color: Colors.orange.shade800,
                    ),
                    const Divider(height: 16),
                    _buildRow(
                      'سود ناخالص فروش:',
                      state.isSecretMode ? 'محرمانه' : formatPrice(grossProfit, showUnit: true),
                      isBold: true,
                      color: Colors.blue.shade800,
                    ),
                    const Divider(height: 16),
                    _buildRow('هزینه‌های جاری انبار (اجاره، ترخیص، باربری):', formatPrice(totalExpenses, showUnit: true), color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
