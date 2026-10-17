import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import '../../utils/calculations.dart';
import '../../theme/app_theme.dart';
import '../invoices/invoice_editor_screen.dart';
import '../inventory/inventory_screen.dart';
import '../customers/customers_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    final liquidity = calculateLiquidity(
      products: state.products,
      invoices: state.invoices,
      customers: state.customers,
      payments: state.payments,
      returns: state.returns,
      treasury: state.treasury,
    );

    final lowStockProducts = state.products.where((p) => p.stockPieces < 1000).toList();
    final recentInvoices = state.invoices.take(5).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Local state is already live in memory
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Header Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary,
                      primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.settings.bismillah,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            toPersianDigits(getCurrentPersianDate()),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.settings.brandName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.settings.subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Actions Row
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context: context,
                      title: 'فاکتور فروش',
                      icon: Icons.add_shopping_cart,
                      color: AppColors.success,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InvoiceEditorScreen(isPurchase: false),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionButton(
                      context: context,
                      title: 'فاکتور خرید',
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.info,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InvoiceEditorScreen(isPurchase: true),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionButton(
                      context: context,
                      title: 'مشتریان',
                      icon: Icons.people_alt_outlined,
                      color: Colors.purple,
                      onTap: () {
                        state.setBottomNavIndex(3);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Metrics Overview Grid
              const Text(
                'آمار و وضعیت کلی بازرگانی',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: 'ارزش سرمایه انبار',
                      value: state.isSecretMode
                          ? 'محرمانه'
                          : formatPrice(liquidity.inventoryCostValue, showUnit: true),
                      icon: Icons.warehouse,
                      iconColor: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: 'کل طلب‌ها از بازار',
                      value: formatPrice(liquidity.totalReceivables, showUnit: true),
                      icon: Icons.trending_up,
                      iconColor: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: 'موجودی نقدینگی',
                      value: formatPrice(liquidity.totalLiquidity, showUnit: true),
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      title: 'بدهی به تامین‌کنندگان',
                      value: formatPrice(liquidity.totalPayables, showUnit: true),
                      icon: Icons.trending_down,
                      iconColor: AppColors.danger,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Low Stock Alert Section
              if (lowStockProducts.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'هشدار کسری موجودی (${toPersianDigits(lowStockProducts.length)})',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => state.setBottomNavIndex(1),
                      child: const Text('مشاهده انبار'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lowStockProducts.take(3).length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final prod = lowStockProducts[idx];
                      return ListTile(
                        title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text(
                          formatStockBreakdown(prod.stockPieces, prod.piecesPerCarton),
                          style: const TextStyle(fontSize: 12, color: AppColors.danger),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'نیاز به شارژ',
                            style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent Invoices
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'آخرین فاکتورهای صادره',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => state.setBottomNavIndex(2),
                    child: const Text('مشاهده همه'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentInvoices.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text('هنوز فاکتوری ثبت نشده است', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentInvoices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final inv = recentInvoices[idx];
                      final isSale = inv.type == 'sale';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSale
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.info.withOpacity(0.12),
                          child: Icon(
                            isSale ? Icons.arrow_outward : Icons.arrow_downward,
                            color: isSale ? AppColors.success : AppColors.info,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          inv.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          'فاکتور شماره ${toPersianDigits(inv.invoiceNumber)} - ${toPersianDigits(inv.date)}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: Text(
                          formatPrice(inv.finalAmount, showUnit: true),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.12) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: iconColor.withOpacity(0.12),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
