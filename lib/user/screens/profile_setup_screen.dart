import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_providers.dart';
import 'user_home_shell.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSetupScreen> createState() => ProfileSetupScreenState();
}

class ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color leafGreen = Color(0xFF8AEB86);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color fieldFill = Color(0xFFF3EEDD);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final bioController = TextEditingController();

  File? avatarFile;

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    bioController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: darkTeal, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: darkTeal, size: 20),
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: vibrantGreen, width: 1.6),
      ),
    );
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => avatarFile = File(picked.path));
    }
  }

  Future<void> handleContinue() async {
    if (!formKey.currentState!.validate()) return;

    await ref.read(profileSetupNotifierProvider.notifier).saveProfile(
          name: nameController.text.trim(),
          avatarFile: avatarFile,
          city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
          bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(profileSetupNotifierProvider);
    if (state.isSaved) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserHomeShell()),
      );
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupNotifierProvider);

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Set up your profile',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: darkText),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tell us a little about you to get started.',
                  style: TextStyle(fontSize: 14, color: darkTeal.withOpacity(0.85), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: pickAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: fieldFill,
                            image: avatarFile != null
                                ? DecorationImage(image: FileImage(avatarFile!), fit: BoxFit.cover)
                                : null,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
                            ],
                          ),
                          child: avatarFile == null
                              ? const Icon(Icons.person_outline_rounded, color: darkTeal, size: 40)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [vibrantGreen, leafGreen]),
                            ),
                            child: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('Add a photo (optional)', style: TextStyle(color: darkTeal, fontSize: 12)),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: darkText),
                  decoration: buildInputDecoration(label: 'Your name', icon: Icons.badge_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cityController,
                  style: const TextStyle(color: darkText),
                  decoration: buildInputDecoration(label: 'City (optional)', icon: Icons.location_city_outlined),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: bioController,
                  maxLines: 2,
                  style: const TextStyle(color: darkText),
                  decoration: buildInputDecoration(label: 'Short bio (optional)', icon: Icons.notes_outlined),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vibrantGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: setupState.isSaving ? null : handleContinue,
                    child: setupState.isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Text('Get started', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
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