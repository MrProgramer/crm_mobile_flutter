import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import '../../utils/calculations.dart';
import 'customer_statement_screen.dart';
import 'customer_form_dialog.dart';
import 'customer_shot_dialog.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final filtered = state.customers.where((c) {
      final q = normalizePersianText(_searchQuery);
      final matchesSearch = normalizePersianText(c.name).contains(q) ||
          normalizePersianText(c.phone).contains(q) ||
          normalizePersianText(c.city).contains(q) ||
          (c.company != null && normalizePersianText(c.company!).contains(q));

      final matchesType = _filterType == 'all' || c.customerType == _filterType;
      return matchesSearch && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('طرف‌های حساب و مشتریان'),
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'جستجوی نام، تلفن یا شهر مشتری...',
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
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('همه', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('عاملین پخش', 'distributor'),
                      const SizedBox(width: 8),
                      _buildFilterChip('تأمین‌کنندگان', 'supplier'),
                      const SizedBox(width: 8),
                      _buildFilterChip('مشتریان عادی', 'regular'),
                      const SizedBox(width: 8),
                      _buildFilterChip('همکاران', 'partner'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Customers List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text('هیچ مشتری یافت نشد', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final c = filtered[idx];
                      final balance = calculateCustomerLiveBalance(
                        c,
                        state.invoices,
                        state.payments,
                        state.returns,
                      );
                      final isDebtor = balance > 0;
                      final isCreditor = balance < 0;

                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerStatementScreen(customer: c),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: isDebtor
                                      ? Colors.red.withOpacity(0.12)
                                      : (isCreditor ? Colors.green.withOpacity(0.12) : Colors.blue.withOpacity(0.12)),
                                  child: Icon(
                                    Icons.person,
                                    color: isDebtor
                                        ? Colors.red
                                        : (isCreditor ? Colors.green : Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${toPersianDigits(c.phone)} - ${c.city}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDebtor
                                            ? Colors.red.withOpacity(0.12)
                                            : (isCreditor ? Colors.green.withOpacity(0.12) : Colors.blue.withOpacity(0.12)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isDebtor
                                            ? 'بدهکار: ${formatPrice(balance.abs(), showUnit: true)}'
                                            : (isCreditor
                                                ? 'بستانکار: ${formatPrice(balance.abs(), showUnit: true)}'
                                                : 'تسویه شده'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isDebtor
                                              ? Colors.red.shade800
                                              : (isCreditor ? Colors.green.shade800 : Colors.blue.shade800),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    IconButton(
                                      icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.blue),
                                      tooltip: 'شات حساب',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => CustomerShotDialog(customer: c),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
            builder: (_) => const CustomerFormDialog(),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('مشتری جدید'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterType = value),
    );
  }
}
