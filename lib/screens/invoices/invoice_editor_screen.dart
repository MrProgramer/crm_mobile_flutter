import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import '../../models/customer.dart';
import '../../models/product.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import 'invoice_detail_screen.dart';

class InvoiceEditorScreen extends StatefulWidget {
  final Invoice? invoiceToEdit;
  final bool isPurchase;
  final Customer? preselectedCustomer;

  const InvoiceEditorScreen({
    super.key,
    this.invoiceToEdit,
    this.isPurchase = false,
    this.preselectedCustomer,
  });

  @override
  State<InvoiceEditorScreen> createState() => _InvoiceEditorScreenState();
}

class _InvoiceEditorScreenState extends State<InvoiceEditorScreen> {
  late bool _isPurchase;
  late bool _isDraft;
  late String _invoiceNumber;
  late String _date;
  late String _time;

  Customer? _selectedCustomer;
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerCityController = TextEditingController();

  List<InvoiceItem> _items = [];
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');
  final _paidAmountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  String _paymentStatus = 'cash'; // cash, credit, partial
  String _paymentAccount = 'cash'; // cash, bank

  @override
  void initState() {
    super.initState();
    final edit = widget.invoiceToEdit;
    final state = context.read<AppState>();

    _isPurchase = edit != null ? (edit.type == 'purchase') : widget.isPurchase;
    _isDraft = edit?.isDraft ?? false;
    _invoiceNumber = edit?.invoiceNumber ?? state.getNextInvoiceNumber();
    _date = edit?.date ?? getCurrentPersianDate();
    _time = edit?.time ?? getCurrentPersianTime();

    if (edit != null) {
      _customerNameController.text = edit.customerName;
      _customerPhoneController.text = edit.customerPhone;
      _customerCityController.text = edit.customerCity;
      _items = List.from(edit.items);
      _discountController.text = edit.discount.round().toString();
      _taxController.text = edit.tax.round().toString();
      _paidAmountController.text = (edit.paidAmount ?? 0).round().toString();
      _paymentStatus = edit.paymentStatus ?? 'cash';
      _paymentAccount = edit.paymentAccount ?? 'cash';
      _notesController.text = edit.notes ?? '';

      if (edit.customerId != null) {
        _selectedCustomer = state.customers.cast<Customer?>().firstWhere(
              (c) => c?.id == edit.customerId,
              orElse: () => null,
            );
      }
    } else if (widget.preselectedCustomer != null) {
      _selectedCustomer = widget.preselectedCustomer;
      _customerNameController.text = widget.preselectedCustomer!.name;
      _customerPhoneController.text = widget.preselectedCustomer!.phone;
      _customerCityController.text = widget.preselectedCustomer!.city;
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerCityController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0.0, (sum, it) => sum + it.totalPrice);
  double get _discount => double.tryParse(toEnglishDigits(_discountController.text)) ?? 0.0;
  double get _tax => double.tryParse(toEnglishDigits(_taxController.text)) ?? 0.0;
  double get _finalAmount => (_subtotal - _discount + _tax).clamp(0.0, double.infinity);
  double get _paidAmount => double.tryParse(toEnglishDigits(_paidAmountController.text)) ?? 0.0;
  double get _remainingAmount => (_finalAmount - _paidAmount).clamp(0.0, double.infinity);

  void _addItem(Product product) {
    final defaultPrice = _isPurchase ? product.purchasePrice : product.sellingPrice;
    final item = InvoiceItem.calculate(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 4)}',
      productId: product.id,
      productName: product.name,
      category: product.category,
      unitTitle: product.unitTitle,
      cartonsCount: 1,
      extraPieces: 0,
      piecesPerCarton: product.piecesPerCarton,
      unitPurchasePrice: product.purchasePrice,
      unitSellingPrice: defaultPrice,
      coverPrice: product.coverPrice,
    );

    setState(() {
      _items.add(item);
    });
  }

  void _saveInvoice() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل یک ردیف کالا به فاکتور اضافه کنید'), backgroundColor: Colors.orange),
      );
      return;
    }

    final custName = _customerNameController.text.trim();
    if (custName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نام طرف حساب الزامی است'), backgroundColor: Colors.orange),
      );
      return;
    }

    final invoice = Invoice(
      id: widget.invoiceToEdit?.id ?? 'inv-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 5)}',
      invoiceNumber: _invoiceNumber,
      date: _date,
      time: _time,
      type: _isPurchase ? 'purchase' : 'sale',
      paymentStatus: _paymentStatus,
      paidAmount: _paymentStatus == 'partial' ? _paidAmount : (_paymentStatus == 'cash' ? _finalAmount : 0.0),
      remainingAmount: _paymentStatus == 'partial' ? _remainingAmount : (_paymentStatus == 'credit' ? _finalAmount : 0.0),
      paymentAccount: _paymentAccount,
      isDraft: _isDraft,
      customerId: _selectedCustomer?.id,
      customerName: custName,
      customerPhone: _customerPhoneController.text.trim(),
      customerCity: _customerCityController.text.trim(),
      salesType: 'نقدی عادی',
      paymentMethod: _paymentStatus == 'cash'
          ? 'نقدی (تسویه شده)'
          : (_paymentStatus == 'credit' ? 'غیر نقدی (نسیه)' : 'پرداخت بخشی (بیعانه)'),
      items: _items,
      subtotal: _subtotal,
      discount: _discount,
      tax: _tax,
      finalAmount: _finalAmount,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: widget.invoiceToEdit?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
    );

    final state = context.read<AppState>();
    if (widget.invoiceToEdit != null) {
      state.updateInvoice(invoice);
    } else {
      state.addInvoice(invoice);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoice: invoice)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoiceToEdit != null
              ? 'ویرایش فاکتور شماره ${toPersianDigits(_invoiceNumber)}'
              : (_isPurchase ? 'صدور فاکتور خرید جدید' : 'صدور فاکتور فروش جدید'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            tooltip: 'ذخیره فاکتور',
            onPressed: _saveInvoice,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Type & Status Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('فروش')),
                          ButtonSegment(value: true, label: Text('خرید (ورود بار)')),
                        ],
                        selected: {_isPurchase},
                        onSelectionChanged: (val) {
                          setState(() => _isPurchase = val.first);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('پیش‌نویس'),
                      selected: _isDraft,
                      onSelected: (val) => setState(() => _isDraft = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Customer Selector Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'اطلاعات طرف حساب / مشتری',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        TextButton.icon(
                          onPressed: () => _openCustomerPicker(context, state),
                          icon: const Icon(Icons.contacts, size: 16),
                          label: const Text('انتخاب از لیست'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(labelText: 'نام و نام خانوادگی طرف حساب *'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _customerPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(labelText: 'شماره تماس'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _customerCityController,
                            decoration: const InputDecoration(labelText: 'شهر / مقصد'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'اقلام فاکتور (${toPersianDigits(_items.length)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openProductPicker(context, state),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('افزودن کالا'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.add_shopping_cart, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text('هنوز کالایی به فاکتور اضافه نشده است', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final it = _items[idx];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue.withOpacity(0.12),
                                child: Text(toPersianDigits(idx + 1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(it.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() => _items.removeAt(idx));
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: it.cartonsCount.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'کارتن', isDense: true),
                                  onChanged: (val) {
                                    final cartons = int.tryParse(toEnglishDigits(val)) ?? 0;
                                    setState(() {
                                      _items[idx] = InvoiceItem.calculate(
                                        id: it.id,
                                        productId: it.productId,
                                        productName: it.productName,
                                        cartonsCount: cartons,
                                        extraPieces: it.extraPieces,
                                        piecesPerCarton: it.piecesPerCarton,
                                        unitPurchasePrice: it.unitPurchasePrice,
                                        unitSellingPrice: it.unitSellingPrice,
                                        coverPrice: it.coverPrice,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: it.extraPieces.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'دانه اضافه', isDense: true),
                                  onChanged: (val) {
                                    final extra = int.tryParse(toEnglishDigits(val)) ?? 0;
                                    setState(() {
                                      _items[idx] = InvoiceItem.calculate(
                                        id: it.id,
                                        productId: it.productId,
                                        productName: it.productName,
                                        cartonsCount: it.cartonsCount,
                                        extraPieces: extra,
                                        piecesPerCarton: it.piecesPerCarton,
                                        unitPurchasePrice: it.unitPurchasePrice,
                                        unitSellingPrice: it.unitSellingPrice,
                                        coverPrice: it.coverPrice,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: it.unitSellingPrice.round().toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'قیمت فی (تومان)', isDense: true),
                                  onChanged: (val) {
                                    final price = double.tryParse(toEnglishDigits(val)) ?? 0.0;
                                    setState(() {
                                      _items[idx] = InvoiceItem.calculate(
                                        id: it.id,
                                        productId: it.productId,
                                        productName: it.productName,
                                        cartonsCount: it.cartonsCount,
                                        extraPieces: it.extraPieces,
                                        piecesPerCarton: it.piecesPerCarton,
                                        unitPurchasePrice: it.unitPurchasePrice,
                                        unitSellingPrice: price,
                                        coverPrice: it.coverPrice,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'تعداد کل: ${toPersianDigits(it.totalPieces)} عدد',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'مبلغ کل: ${formatPrice(it.totalPrice, showUnit: true)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

            const SizedBox(height: 20),

            // Financial Summary & Payment Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تسویه و محاسبات نهایی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('جمع ناخالص فاکتور:'),
                        Text(formatPrice(_subtotal, showUnit: true), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'تخفیف (تومان)', isDense: true),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _taxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'مالیات / عوارض', isDense: true),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مبلغ نهایی قابل پرداخت:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          formatPrice(_finalAmount, showUnit: true),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Payment Mode Segmented Button
                    const Text('وضعیت پرداخت:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'cash', label: Text('نقدی')),
                        ButtonSegment(value: 'credit', label: Text('نسیه (اعتباری)')),
                        ButtonSegment(value: 'partial', label: Text('بیعانه')),
                      ],
                      selected: {_paymentStatus},
                      onSelectionChanged: (val) {
                        setState(() {
                          _paymentStatus = val.first;
                          if (_paymentStatus == 'partial' && _paidAmount == 0) {
                            _paidAmountController.text = (_finalAmount / 2).round().toString();
                          }
                        });
                      },
                    ),

                    if (_paymentStatus == 'partial') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _paidAmountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'مبلغ پرداختی نقدی (تومان)', isDense: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('مانده بدهی فاکتور:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                Text(
                                  formatPrice(_remainingAmount, showUnit: true),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'توضیحات و شرایط فاکتور (اختیاری)', isDense: true),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveInvoice,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('ثبت نهایی و مشاهده فاکتور', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _openProductPicker(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final prods = state.products.where((p) => normalizePersianText(p.name).contains(normalizePersianText(filter))).toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('انتخاب کالا جهت افزودن به فاکتور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  TextField(
                    decoration: const InputDecoration(hintText: 'جستجوی سریع نام کالا...', prefixIcon: Icon(Icons.search)),
                    onChanged: (val) => setModalState(() => filter = val),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: prods.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, idx) {
                        final p = prods[idx];
                        return ListTile(
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                            'موجودی: ${formatStockBreakdown(p.stockPieces, p.piecesPerCarton)} | قیمت: ${formatPrice(p.sellingPrice, showUnit: true)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.add_circle_outline, color: Colors.blue),
                          onTap: () {
                            _addItem(p);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCustomerPicker(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('انتخاب طرف حساب از لیست', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: state.customers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, idx) {
                    final c = state.customers[idx];
                    return ListTile(
                      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${c.phone} - ${c.city}'),
                      onTap: () {
                        setState(() {
                          _selectedCustomer = c;
                          _customerNameController.text = c.name;
                          _customerPhoneController.text = c.phone;
                          _customerCityController.text = c.city;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
