import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/scan_providers.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductDetail product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color cardFill = Color(0xFFF3EEDD);

  Future<void> openDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${product.store.latitude},${product.store.longitude}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Widget buildAttributeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: darkTeal)),
          Text(value, style: const TextStyle(color: darkText, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkTeal),
        title: const Text(
          'Product details',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  height: 220,
                  color: cardFill,
                  child: const Icon(Icons.inventory_2_outlined, color: darkTeal, size: 48),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              product.name,
              style: const TextStyle(color: darkText, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (product.brand != null) ...[
              const SizedBox(height: 4),
              Text(product.brand!, style: const TextStyle(color: darkTeal)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: darkTeal, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: vibrantGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${product.ecoScore}/100 Eco Score',
                    style: const TextStyle(color: vibrantGreen, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            if (product.description != null) ...[
              const SizedBox(height: 16),
              Text(product.description!, style: const TextStyle(color: darkText)),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardFill, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  buildAttributeRow('Material', product.material),
                  buildAttributeRow('Recyclable', product.recyclable),
                  buildAttributeRow('Reusable', product.reusable),
                  buildAttributeRow('Certification', product.certification),
                  buildAttributeRow('Packaging', product.packaging),
                  if (product.category != null)
                    buildAttributeRow('Category', product.category!),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sold at',
              style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardFill, borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: vibrantGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.store.name,
                          style: const TextStyle(color: darkText, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(product.store.address, style: const TextStyle(color: darkTeal, fontSize: 13)),
                  if (product.store.phone != null) ...[
                    const SizedBox(height: 4),
                    Text(product.store.phone!, style: const TextStyle(color: darkTeal, fontSize: 13)),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: vibrantGreen, width: 1.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: openDirections,
                      icon: const Icon(Icons.directions_rounded, color: vibrantGreen),
                      label: const Text(
                        'Get directions',
                        style: TextStyle(color: vibrantGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}