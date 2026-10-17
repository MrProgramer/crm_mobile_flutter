import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';

class InwardStockDialog extends StatefulWidget {
  final Product? preselectedProduct;

  const InwardStockDialog({super.key, this.preselectedProduct});

  @override
  State<InwardStockDialog> createState() => _InwardStockDialogState();
}

class _InwardStockDialogState extends State<InwardStockDialog> {
  Product? _selectedProduct;
  final _cartonsController = TextEditingController(text: '10');
  final _extraPiecesController = TextEditingController(text: '0');
  late TextEditingController _purchasePriceController;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.preselectedProduct;
    _purchasePriceController = TextEditingController(
      text: _selectedProduct != null ? _selectedProduct!.purchasePrice.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _cartonsController.dispose();
    _extraPiecesController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedProduct == null) return;

    final cartons = int.tryParse(toEnglishDigits(_cartonsController.text)) ?? 0;
    final extra = int.tryParse(toEnglishDigits(_extraPiecesController.text)) ?? 0;
    final totalAdded = (cartons * _selectedProduct!.piecesPerCarton) + extra;

    if (totalAdded <= 0) return;

    final newPrice = double.tryParse(toEnglishDigits(_purchasePriceController.text));

    context.read<AppState>().inwardStock(
          productId: _selectedProduct!.id,
          addedPieces: totalAdded,
          newPurchasePrice: newPrice,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('موجودی کالای "${_selectedProduct!.name}" با موفقیت شارژ شد.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ورود بار جدید به انبار (شارژ موجودی)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Product Dropdown
              if (widget.preselectedProduct == null) ...[
                const Text('انتخاب کالا:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  items: state.products.map((p) {
                    return DropdownMenuItem<Product>(
                      value: p,
                      child: Text(p.name, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProduct = val;
                      if (val != null) {
                        _purchasePriceController.text = val.purchasePrice.round().toString();
                      }
                    });
                  },
                  decoration: const InputDecoration(hintText: 'کالای مورد نظر را انتخاب کنید'),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.preselectedProduct!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_selectedProduct != null) ...[
                Text(
                  'موجودی فعلی: ${formatStockBreakdown(_selectedProduct!.stockPieces, _selectedProduct!.piecesPerCarton)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cartonsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'تعداد کارتن ورودی'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _extraPiecesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'دانه اضافه'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _purchasePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'قیمت خرید جدید هر واحد (تومان)',
                    hintText: 'در صورت تغییر قیمت فاکتور خرید',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('ثبت ورود بار و افزایش موجودی'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
