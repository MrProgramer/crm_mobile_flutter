import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import '../../theme/app_theme.dart';
import 'product_form_dialog.dart';
import 'inward_stock_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'همه';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    // Extract categories
    final categories = ['همه', ...state.products.map((p) => p.category).toSet().toList()];

    // Filter products
    final filtered = state.products.where((p) {
      final matchesSearch = normalizePersianText(p.name).contains(normalizePersianText(_searchQuery)) ||
          (p.barcode != null && p.barcode!.contains(_searchQuery));
      final matchesCat = _selectedCategory == 'همه' || p.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    // Summary calculations
    double totalValuation = 0;
    for (final p in state.products) {
      totalValuation += p.stockPieces * p.purchasePrice;
    }

    return Scaffold(
      body: Column(
        children: [
          // Header Search & Valuation
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'جستجوی نام کالا یا بارکد...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),

                // Category chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = categories[idx];
                      final isSelected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text('هیچ کالایی یافت نشد', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final prod = filtered[idx];
                      final isLowStock = prod.stockPieces < 1000;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prod.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            prod.category,
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ProductFormDialog(product: prod),
                                        );
                                      } else if (action == 'inward') {
                                        showDialog(
                                          context: context,
                                          builder: (_) => InwardStockDialog(preselectedProduct: prod),
                                        );
                                      } else if (action == 'delete') {
                                        _confirmDelete(context, prod);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'inward',
                                        child: Row(
                                          children: [
                                            Icon(Icons.add_box_outlined, color: Colors.green, size: 18),
                                            SizedBox(width: 8),
                                            Text('ورود بار و شارژ موجودی', style: TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 18),
                                            SizedBox(width: 8),
                                            Text('ویرایش مشخصات کالا', style: TextStyle(fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                            SizedBox(width: 8),
                                            Text('حذف کالا', style: TextStyle(fontSize: 13, color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Stock Breakdown Badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isLowStock ? AppColors.danger.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isLowStock ? AppColors.danger.withOpacity(0.3) : AppColors.success.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.inventory_2,
                                          size: 14,
                                          color: isLowStock ? AppColors.danger : AppColors.success,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          formatStockBreakdown(prod.stockPieces, prod.piecesPerCarton),
                                          style: TextStyle(
                                            color: isLowStock ? AppColors.danger : AppColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'کارتن: ${toPersianDigits(prod.piecesPerCarton)} دانه',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),

                              // Pricing Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('قیمت فروش:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(
                                        formatPrice(prod.sellingPrice, showUnit: true),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  if (prod.coverPrice != null && prod.coverPrice! > 0)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('روی جلد:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        Text(
                                          formatPrice(prod.coverPrice, showUnit: true),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blueGrey,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('قیمت خرید:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(
                                        state.isSecretMode
                                            ? '*** محرمانه ***'
                                            : formatPrice(prod.purchasePrice, showUnit: true),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: state.isSecretMode ? Colors.grey : AppColors.danger,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const ProductFormDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('کالای جدید'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف کالا از انبار'),
        content: Text('آیا از حذف کامل کالای "${product.name}" اطمینان دارید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AppState>().deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: const Text('حذف کالا'),
          ),
        ],
      ),
    );
  }
}
