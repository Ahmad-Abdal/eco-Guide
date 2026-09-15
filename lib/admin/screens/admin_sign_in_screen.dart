import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_providers.dart';
import 'admin_home_screen.dart';

class AdminSignInScreen extends ConsumerStatefulWidget {
  const AdminSignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminSignInScreen> createState() => AdminSignInScreenState();
}

class AdminSignInScreenState extends ConsumerState<AdminSignInScreen> {
  static const Color pureWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color primaryGreen = Color(0xFF1B7A43);
  static const Color lightGreenBg = Color(0xFFE7F4EC);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color sectionFill = Color(0xFFF7F8F6);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textGray, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: primaryGreen, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: sectionFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderGray, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderGray, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  Future<void> handleAdminSignIn() async {
    if (!formKey.currentState!.validate()) return;

    await ref.read(adminAuthNotifierProvider.notifier).signIn(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

    if (!mounted) return;

    final authState = ref.read(adminAuthNotifierProvider);
    if (authState.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminHomeScreen(),
        ),
      );
    } else if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthNotifierProvider);

    return Scaffold(
      backgroundColor: pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: textDark),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightGreenBg,
                      border: Border.all(color: borderGray, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 52,
                      color: primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Admin login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Restricted access for the EcoWise admin account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: textDark),
                  decoration: buildInputDecoration(
                    label: 'Admin email',
                    icon: Icons.mail_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the admin email';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: const TextStyle(color: textDark),
                  decoration: buildInputDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: textGray,
                      ),
                      onPressed: () {
                        setState(() => obscurePassword = !obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter the password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: authState.isLoading ? null : handleAdminSignIn,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign in as admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Only one admin account exists for this app.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}