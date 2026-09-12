import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/scan_providers.dart';
import 'product_detail_screen.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanScreen> createState() => ScanScreenState();
}

class ScanScreenState extends ConsumerState<ScanScreen> {
  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color fieldFill = Color(0xFFF3EEDD);

  final manualIdController = TextEditingController();
  final scannerController = MobileScannerController();

  bool isHandlingScan = false;

  @override
  void dispose() {
    manualIdController.dispose();
    scannerController.dispose();
    super.dispose();
  }

  Future<void> handleDetection(BarcodeCapture capture) async {
    if (isHandlingScan) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) return;

    isHandlingScan = true;
    await scannerController.stop();
    await lookupAndOpen(code);
  }

  Future<void> lookupAndOpen(String code) async {
    await ref.read(productLookupNotifierProvider.notifier).lookupProduct(code);
    if (!mounted) return;

    final lookupState = ref.read(productLookupNotifierProvider);

    if (lookupState.product != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: lookupState.product!),
        ),
      );
    } else if (lookupState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lookupState.errorMessage!)),
      );
    }

    ref.read(productLookupNotifierProvider.notifier).reset();
    isHandlingScan = false;
    if (mounted) await scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    final lookupState = ref.watch(productLookupNotifierProvider);

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              children: const [
                Icon(Icons.qr_code_scanner_rounded, color: vibrantGreen, size: 24),
                SizedBox(width: 8),
                Text(
                  'Scan & Save',
                  style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 280,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: scannerController,
                      onDetect: handleDetection,
                    ),
                    if (lookupState.isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.45),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: vibrantGreen, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Point your camera at a product QR code',
                style: TextStyle(color: darkTeal, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Or enter product ID manually',
              style: TextStyle(color: darkText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: manualIdController,
                    style: const TextStyle(color: darkText),
                    decoration: InputDecoration(
                      hintText: 'Enter product ID',
                      filled: true,
                      fillColor: fieldFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  width: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vibrantGreen,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => lookupAndOpen(manualIdController.text),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: const [
                Icon(Icons.favorite_rounded, color: vibrantGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  'My Wishlist',
                  style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(color: fieldFill, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  Icon(Icons.favorite_border_rounded, color: darkTeal.withOpacity(0.6), size: 30),
                  const SizedBox(height: 10),
                  Text(
                    'Products you save will show up here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: darkTeal.withOpacity(0.8), fontSize: 13),
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