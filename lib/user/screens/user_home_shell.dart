import 'package:flutter/material.dart';
import '../widgets/rounded_bottom_nav.dart';
import '../widgets/chat_fab.dart';
import 'home_screen.dart';
import 'stores_screen.dart';
import 'scan_screen.dart';
import 'browse_screen.dart';
import 'wishlist_screen.dart';

class UserHomeShell extends StatefulWidget {
  const UserHomeShell({Key? key}) : super(key: key);

  @override
  State<UserHomeShell> createState() => UserHomeShellState();
}

class UserHomeShellState extends State<UserHomeShell> {
  static const Color appBackground = Color(0xFFFFFFFF);

  int selectedIndex = 0;

  static const tabs = [
    UserHomeScreen(),
    StoresScreen(),
    ScanScreen(),
    BrowseScreen(),
    WishlistScreen(),
  ];

  static const navItems = [
    NavItemData(icon: Icons.home_rounded, label: 'Home'),
    NavItemData(icon: Icons.storefront_rounded, label: 'Stores'),
    NavItemData(icon: Icons.qr_code_scanner_rounded, label: 'Scan'),
    NavItemData(icon: Icons.search_rounded, label: 'Search'),
    NavItemData(icon: Icons.favorite_border_rounded, label: 'Wishlist'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            IndexedStack(index: selectedIndex, children: tabs),
            const ChatFab(),
          ],
        ),
      ),
      bottomNavigationBar: RoundedBottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: navItems,
      ),
    );
  }
}