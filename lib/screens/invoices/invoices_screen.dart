import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import '../../theme/app_theme.dart';
import 'invoice_editor_screen.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('بایگانی و مدیریت فاکتورها'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'همه (${toPersianDigits(state.invoices.length)})'),
            Tab(text: 'فروش (${toPersianDigits(state.invoices.where((i) => !i.isDraft && i.type == 'sale').length)})'),
            Tab(text: 'خرید (${toPersianDigits(state.invoices.where((i) => !i.isDraft && i.type == 'purchase').length)})'),
            Tab(text: 'پیش‌نویس‌ها (${toPersianDigits(state.invoices.where((i) => i.isDraft).length)})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجوی شماره فاکتور یا نام مشتری...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Tabs Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInvoiceList(state.invoices),
                _buildInvoiceList(state.invoices.where((i) => !i.isDraft && i.type == 'sale').toList()),
                _buildInvoiceList(state.invoices.where((i) => !i.isDraft && i.type == 'purchase').toList()),
                _buildInvoiceList(state.invoices.where((i) => i.isDraft).toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InvoiceEditorScreen(isPurchase: false),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('فاکتور جدید'),
      ),
    );
  }

  Widget _buildInvoiceList(List<Invoice> invoiceList) {
    final filtered = invoiceList.where((inv) {
      final q = normalizePersianText(_searchQuery);
      return normalizePersianText(inv.customerName).contains(q) ||
          normalizePersianText(inv.invoiceNumber).contains(q) ||
          normalizePersianText(inv.customerCity).contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text('فاکتوری در این بخش یافت نشد', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final inv = filtered[idx];
        final isSale = inv.type == 'sale';

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceDetailScreen(invoice: inv),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSale ? Colors.green.shade50 : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isSale ? 'فروش' : 'خرید',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSale ? Colors.green.shade700 : Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'فاکتور شماره ${toPersianDigits(inv.invoiceNumber)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        toPersianDigits(inv.date),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        inv.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        formatPrice(inv.finalAmount, showUnit: true),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: inv.paymentStatus == 'cash'
                              ? Colors.green.withOpacity(0.12)
                              : (inv.paymentStatus == 'partial' ? Colors.orange.withOpacity(0.12) : Colors.red.withOpacity(0.12)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          inv.paymentMethod,
                          style: TextStyle(
                            fontSize: 11,
                            color: inv.paymentStatus == 'cash'
                                ? Colors.green.shade800
                                : (inv.paymentStatus == 'partial' ? Colors.orange.shade800 : Colors.red.shade800),
                          ),
                        ),
                      ),
                      Text(
                        '${toPersianDigits(inv.items.length)} قلم کالا',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
