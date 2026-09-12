import 'package:flutter/material.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  static const Color darkText = Color(0xFF2F4F4F);
  static const Color darkTeal = Color(0xFF1C7043);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_rounded, size: 48, color: darkTeal),
          const SizedBox(height: 12),
          const Text(
            'Users',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'User management coming soon.',
            style: TextStyle(color: darkTeal.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}