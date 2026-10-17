import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'dashboard/dashboard_screen.dart';
import 'inventory/inventory_screen.dart';
import 'invoices/invoices_screen.dart';
import 'customers/customers_screen.dart';
import 'treasury/treasury_screen.dart';
import 'returns/returns_screen.dart';
import 'profit_loss/profit_loss_screen.dart';
import 'backup/backup_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final screens = [
      const DashboardScreen(),
      const InventoryScreen(),
      const InvoicesScreen(),
      const CustomersScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              state.settings.brandName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            if (state.isSecretMode) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility_off, size: 12, color: Colors.amber),
                    SizedBox(width: 4),
                    Text('محرمانه', style: TextStyle(fontSize: 10, color: Colors.amber)),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              state.isSecretMode ? Icons.visibility_off : Icons.visibility,
              color: state.isSecretMode ? Colors.amber : null,
            ),
            tooltip: 'حالت محرمانه (پنهان‌سازی سود و قیمت خرید)',
            onPressed: () => state.toggleSecretMode(),
          ),
          IconButton(
            icon: Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'حالت شب / روز',
            onPressed: () => state.toggleDarkMode(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(state.settings.brandName, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(state.settings.phone),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  state.settings.brandName.isNotEmpty ? state.settings.brandName[0] : 'ب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('پیشخوان اصلی'),
              onTap: () {
                state.setBottomNavIndex(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse_outlined),
              title: const Text('انبارداری و موجودی کالا'),
              onTap: () {
                state.setBottomNavIndex(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('بایگانی فاکتورها'),
              onTap: () {
                state.setBottomNavIndex(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_outlined),
              title: const Text('مشتریان و صورت‌حساب‌ها'),
              onTap: () {
                state.setBottomNavIndex(3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.teal),
              title: const Text('صندوق، بانک و نقدینگی'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TreasuryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return_outlined, color: Colors.orange),
              title: const Text('مدیریت مرجوعی کالا'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReturnsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined, color: Colors.green),
              title: const Text('گزارش سود و زیان'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitLossScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.blue),
              title: const Text('پشتیبان‌گیری و همگام‌سازی وب'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('تنظیمات برنامه'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      body: screens[state.currentBottomNavIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.currentBottomNavIndex,
        onDestinationSelected: (idx) => state.setBottomNavIndex(idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'پیشخوان',
          ),
          NavigationDestination(
            icon: Icon(Icons.warehouse_outlined),
            selectedIcon: Icon(Icons.warehouse),
            label: 'انبار',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'فاکتورها',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: 'مشتریان',
          ),
        ],
      ),
    );
  }
}
