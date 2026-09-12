import 'package:flutter/material.dart';
import '../widgets/rounded_bottom_nav.dart';
import 'home_screen.dart';
import 'stores_screen.dart';
import 'scan_screen.dart';
import 'tips_screen.dart';
import 'wishlist_screen.dart';

class UserHomeShell extends StatefulWidget {
  const UserHomeShell({Key? key}) : super(key: key);

  @override
  State<UserHomeShell> createState() => UserHomeShellState();
}

class UserHomeShellState extends State<UserHomeShell> {
  static const Color appBackground = Color(0xFFFDF9F0);

  int selectedIndex = 0;

  static const tabs = [
    UserHomeScreen(),
    StoresScreen(),
    ScanScreen(),
    TipsScreen(),
    WishlistScreen(),
  ];

  static const navItems = [
    NavItemData(icon: Icons.home_rounded, label: 'Home'),
    NavItemData(icon: Icons.storefront_rounded, label: 'Stores'),
    NavItemData(icon: Icons.qr_code_scanner_rounded, label: 'Scan'),
    NavItemData(icon: Icons.lightbulb_outline_rounded, label: 'Tips'),
    NavItemData(icon: Icons.favorite_border_rounded, label: 'Wishlist'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: selectedIndex, children: tabs),
      ),
      bottomNavigationBar: RoundedBottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: navItems,
      ),
    );
  }
}