import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _coverPriceController;
  late TextEditingController _piecesPerCartonController;
  late TextEditingController _packsPerCartonController;
  late TextEditingController _piecesPerPackController;
  late TextEditingController _cartonsStockController;
  late TextEditingController _extraPiecesStockController;
  late TextEditingController _barcodeController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? 'مواد غذایی');
    _purchasePriceController = TextEditingController(text: p != null ? p.purchasePrice.round().toString() : '');
    _sellingPriceController = TextEditingController(text: p != null ? p.sellingPrice.round().toString() : '');
    _coverPriceController = TextEditingController(text: p?.coverPrice != null ? p!.coverPrice!.round().toString() : '');
    _piecesPerCartonController = TextEditingController(text: p != null ? p.piecesPerCarton.toString() : '480');
    _packsPerCartonController = TextEditingController(text: p?.packsPerCarton?.toString() ?? '20');
    _piecesPerPackController = TextEditingController(text: p?.piecesPerPack?.toString() ?? '24');

    int cartons = 0;
    int extra = 0;
    if (p != null) {
      cartons = p.cartonsCount;
      extra = p.extraPiecesCount;
    }
    _cartonsStockController = TextEditingController(text: cartons > 0 ? cartons.toString() : '0');
    _extraPiecesStockController = TextEditingController(text: extra > 0 ? extra.toString() : '0');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _coverPriceController.dispose();
    _piecesPerCartonController.dispose();
    _packsPerCartonController.dispose();
    _piecesPerPackController.dispose();
    _cartonsStockController.dispose();
    _extraPiecesStockController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final ppCarton = int.tryParse(toEnglishDigits(_piecesPerCartonController.text)) ?? 1;
    final cartons = int.tryParse(toEnglishDigits(_cartonsStockController.text)) ?? 0;
    final extra = int.tryParse(toEnglishDigits(_extraPiecesStockController.text)) ?? 0;
    final totalStock = (cartons * ppCarton) + extra;

    final product = Product(
      id: widget.product?.id ?? 'prod-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 4)}',
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      purchasePrice: double.tryParse(toEnglishDigits(_purchasePriceController.text)) ?? 0.0,
      sellingPrice: double.tryParse(toEnglishDigits(_sellingPriceController.text)) ?? 0.0,
      coverPrice: double.tryParse(toEnglishDigits(_coverPriceController.text)),
      piecesPerCarton: ppCarton,
      packsPerCarton: int.tryParse(toEnglishDigits(_packsPerCartonController.text)),
      piecesPerPack: int.tryParse(toEnglishDigits(_piecesPerPackController.text)),
      stockPieces: totalStock,
      barcode: _barcodeController.text.trim().isNotEmpty ? _barcodeController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: widget.product?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final state = context.read<AppState>();
    if (widget.product == null) {
      state.addProduct(product);
    } else {
      state.updateProduct(product);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

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
                      isEdit ? 'ویرایش مشخصات کالا' : 'افزودن کالای جدید',
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

                // Name & Category
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'نام کالا *', hintText: 'مثلا آبنبات ترش'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'نام کالا الزامی است' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'دسته‌بندی', hintText: 'مثلا شکلات، کیک، آبنبات'),
                ),
                const SizedBox(height: 16),

                // Pricing
                const Text('قیمت‌گذاری (تومان)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _purchasePriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'قیمت خرید *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'الزامی است' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'قیمت فروش *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'الزامی است' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _coverPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'قیمت مصرف‌کننده (روی جلد) - اختیاری'),
                ),

                const SizedBox(height: 16),

                // Packaging Specs
                const Text('مشخصات بسته‌بندی و تعداد در کارتن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _piecesPerCartonController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'تعداد کل در کارتن *'),
                        validator: (v) => (v == null || v.isEmpty) ? 'الزامی است' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _packsPerCartonController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'بسته در کارتن'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _piecesPerPackController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'دانه در بسته'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Initial Stock
                const Text('موجودی اولیه انبار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cartonsStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'تعداد کارتن'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _extraPiecesStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'دانه اضافه'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(labelText: 'کد بارکد', hintText: 'اختیاری جهت اسکن سریع'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'یادداشت و توضیحات کالا'),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(isEdit ? 'ذخیره تغییرات' : 'ثبت نهایی کالا در انبار'),
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
