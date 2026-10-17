import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/product_return.dart';
import '../../models/product.dart';
import '../../models/customer.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت مرجوعی کالا'),
      ),
      body: state.returns.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_return_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text('هیچ سند مرجوعی ثبت نشده است', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.returns.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final r = state.returns[idx];
                final isFromCustomer = r.type == 'from_customer';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isFromCustomer ? Colors.orange.withOpacity(0.12) : Colors.purple.withOpacity(0.12),
                      child: Icon(
                        isFromCustomer ? Icons.call_received : Icons.call_made,
                        color: isFromCustomer ? Colors.orange : Colors.purple,
                        size: 20,
                      ),
                    ),
                    title: Text('${r.productName} (${toPersianDigits(r.totalPieces)} دانه)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      '${isFromCustomer ? "از مشتری" : "به شرکت"}: ${r.customerName} - ${toPersianDigits(r.date)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formatPrice(r.calculatedNetAmount, showUnit: true), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(r.reason, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    onLongPress: () {
                      state.deleteReturn(r.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddReturnDialog(context, state),
        icon: const Icon(Icons.add),
        label: const Text('سند مرجوعی جدید'),
      ),
    );
  }

  void _openAddReturnDialog(BuildContext context, AppState state) {
    Product? selectedProduct;
    Customer? selectedCustomer;
    String returnType = 'from_customer';
    final countController = TextEditingController(text: '10');
    final reasonController = TextEditingController(text: 'کالای معیوب / تاریخ گذشته');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ثبت مرجوعی کالا', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      const SizedBox(height: 10),

                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'from_customer', label: Text('مرجوع از مشتری')),
                          ButtonSegment(value: 'to_supplier', label: Text('برگشت به شرکت')),
                        ],
                        selected: {returnType},
                        onSelectionChanged: (val) => setState(() => returnType = val.first),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<Product>(
                        value: selectedProduct,
                        decoration: const InputDecoration(labelText: 'کالا'),
                        items: state.products.map((p) => DropdownMenuItem(value: p, child: Text(p.name, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) => setState(() => selectedProduct = v),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<Customer>(
                        value: selectedCustomer,
                        decoration: const InputDecoration(labelText: 'طرف حساب'),
                        items: state.customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) => setState(() => selectedCustomer = v),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: countController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'تعداد کل دانه مرجوعی'),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: reasonController,
                        decoration: const InputDecoration(labelText: 'علت مرجوعی'),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedProduct == null || selectedCustomer == null) return;
                            final count = int.tryParse(toEnglishDigits(countController.text)) ?? 0;
                            if (count <= 0) return;

                            final totalAmt = count * selectedProduct!.sellingPrice;

                            final ret = ProductReturn(
                              id: 'ret-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 4)}',
                              productId: selectedProduct!.id,
                              productName: selectedProduct!.name,
                              customerId: selectedCustomer!.id,
                              customerName: selectedCustomer!.name,
                              type: returnType,
                              totalPieces: count,
                              unitPrice: selectedProduct!.sellingPrice,
                              totalAmount: totalAmt,
                              date: getCurrentPersianDate(),
                              time: getCurrentPersianTime(),
                              reason: reasonController.text.trim(),
                              createdAt: DateTime.now().millisecondsSinceEpoch,
                            );

                            state.addReturn(ret);
                            Navigator.pop(ctx);
                          },
                          child: const Text('ثبت سند مرجوعی'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
