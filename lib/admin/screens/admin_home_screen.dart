import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_stores_screen.dart';
import 'admin_users_screen.dart';
import 'admin_analytics_screen.dart';
import '../../user/widgets/rounded_bottom_nav.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  static const Color pureWhite = Colors.white;

  int selectedIndex = 0;

  void goToTab(int index) {
    setState(() => selectedIndex = index);
  }

  static const tabs = [
    AdminDashboardScreen(),
    AdminStoresScreen(),
    AdminUsersScreen(),
    AdminAnalyticsScreen(),
  ];

  static const navItems = [
    NavItemData(icon: Icons.home_rounded, label: 'Dashboard'),
    NavItemData(icon: Icons.storefront_rounded, label: 'Stores'),
    NavItemData(icon: Icons.people_rounded, label: 'Users'),
    NavItemData(icon: Icons.bar_chart_rounded, label: 'Analytics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureWhite,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: selectedIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: RoundedBottomNav(
        selectedIndex: selectedIndex,
        onTap: goToTab,
        items: navItems,
      ),
    );
  }
}