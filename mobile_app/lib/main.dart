import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/my_impact_screen.dart';
import 'screens/solar_calculator_screen.dart';
import 'screens/money_expenses_screen.dart';
import 'screens/give_back_screen.dart';
import 'screens/analytics_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoBalanceApp());
}

class EcoBalanceApp extends StatelessWidget {
  const EcoBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoBalance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F2937),
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigate: _navigateToIndex),
      const MyImpactScreen(),
      const SolarCalculatorScreen(),
      const MoneyExpensesScreen(),
      const GiveBackScreen(),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF2E7D32)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco, color: Color(0xFF2E7D32)),
            label: 'Impact',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny, color: Color(0xFF2E7D32)),
            label: 'Solar',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF2E7D32)),
            label: 'Money',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism, color: Color(0xFF2E7D32)),
            label: 'Give Back',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: Color(0xFF2E7D32)),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
