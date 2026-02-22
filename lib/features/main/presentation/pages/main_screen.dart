import 'package:flutter/material.dart';
import '../../../../features/transactions/presentation/pages/home_screen.dart';
import '../../../../features/statistics/presentation/pages/statistics_tab.dart';
import '../../../../features/settings/presentation/pages/settings_tab.dart';
import '../../../../features/transactions/presentation/pages/add_transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeScreen(), // This will act as our DashboardTab
    const StatisticsTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF10B981);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
