import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_stores_screen.dart';
import 'admin_users_screen.dart';
import 'admin_analytics_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);

  int selectedIndex = 0;

  void goToTab(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const AdminDashboardScreen(),
      const AdminStoresScreen(),
      const AdminUsersScreen(),
      const AdminAnalyticsScreen(),
    ];

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: goToTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: vibrantGreen,
        unselectedItemColor: darkTeal.withOpacity(0.5),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}