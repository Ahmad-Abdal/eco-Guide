import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/add_store_providers.dart';
import '../providers/dashboard_providers.dart';
import 'pick_location_screen.dart';

class AddStoreScreen extends ConsumerStatefulWidget {
  const AddStoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddStoreScreen> createState() => AddStoreScreenState();
}

class AddStoreScreenState extends ConsumerState<AddStoreScreen> {
  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color fieldFill = Color(0xFFF3EEDD);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();
  final openingHoursController = TextEditingController();
  final descriptionController = TextEditingController();

  File? storeImage;
  PickedLocation? pickedLocation;

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    openingHoursController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: darkTeal),
      prefixIcon: Icon(icon, color: darkTeal),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: vibrantGreen, width: 1.5),
      ),
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => storeImage = File(picked.path));
    }
  }

  Future<void> pickLocation() async {
    final result = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(builder: (context) => const PickLocationScreen()),
    );
    if (result != null) {
      setState(() {
        pickedLocation = result;
        locationController.text = result.address;
      });
    }
  }

  Future<void> handleSave() async {
    if (!formKey.currentState!.validate()) return;

    if (storeImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a store image')),
      );
      return;
    }
    if (pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pin the store location')),
      );
      return;
    }

    await ref.read(addStoreNotifierProvider.notifier).saveStore(
          imageFile: storeImage!,
          name: nameController.text.trim(),
          address: pickedLocation!.address,
          latitude: pickedLocation!.latitude,
          longitude: pickedLocation!.longitude,
          phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
          website: websiteController.text.trim().isEmpty ? null : websiteController.text.trim(),
          openingHours: openingHoursController.text.trim().isEmpty
              ? null
              : openingHoursController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
        );

    if (!mounted) return;

    final saveState = ref.read(addStoreNotifierProvider);
    if (saveState.isSaved) {
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(storesOverviewProvider);
      Navigator.pop(context);
    } else if (saveState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saveState.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(addStoreNotifierProvider);

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkTeal),
        title: const Text(
          'Add store',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: fieldFill,
                        shape: BoxShape.circle,
                        image: storeImage != null
                            ? DecorationImage(
                                image: FileImage(storeImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: storeImage == null
                          ? const Icon(
                              Icons.add_a_photo_outlined,
                              color: darkTeal,
                              size: 32,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Store image (required)',
                    style: TextStyle(color: darkTeal, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: darkText),
                  decoration: buildInputDecoration(
                    label: 'Store name',
                    icon: Icons.storefront_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter the store name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: pickLocation,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: locationController,
                      style: const TextStyle(color: darkText),
                      decoration: buildInputDecoration(
                        label: 'Location',
                        icon: Icons.location_on_outlined,
                        suffixIcon: const Icon(
                          Icons.map_outlined,
                          color: vibrantGreen,
                        ),
                      ),
                      validator: (value) {
                        if (pickedLocation == null) {
                          return 'Pin the store location on the map';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: darkText),
                  decoration: buildInputDecoration(
                    label: 'Phone (optional)',
                    icon: Icons.call_outlined,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: websiteController,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(color: darkText),
                  decoration: buildInputDecoration(
                    label: 'Website (optional)',
                    icon: Icons.language_outlined,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: openingHoursController,
                  maxLines: 2,
                  style: const TextStyle(color: darkText),
                  decoration: buildInputDecoration(
                    label: 'Opening hours (optional)',
                    icon: Icons.schedule_outlined,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: darkText),
                  decoration: buildInputDecoration(
                    label: 'Eco-friendly description (optional)',
                    icon: Icons.eco_outlined,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vibrantGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: saveState.isSaving ? null : handleSave,
                    child: saveState.isSaving
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
                            'Save store',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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