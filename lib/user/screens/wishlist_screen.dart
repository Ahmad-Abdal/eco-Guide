import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wishlist_providers.dart';
import '../providers/scan_providers.dart';
import 'product_detail_screen.dart';

enum WishlistSort { newestFirst, oldestFirst, priceLowToHigh, priceHighToLow }

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WishlistScreen> createState() => WishlistScreenState();
}

class WishlistScreenState extends ConsumerState<WishlistScreen> {
  static const Color pureWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color primaryGreen = Color(0xFF1B7A43);
  static const Color lightGreenBg = Color(0xFFE7F4EC);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color sectionFill = Color(0xFFF7F8F6);

  WishlistSort sort = WishlistSort.newestFirst;

  String get sortLabel {
    switch (sort) {
      case WishlistSort.newestFirst:
        return 'Newest first';
      case WishlistSort.oldestFirst:
        return 'Oldest first';
      case WishlistSort.priceLowToHigh:
        return 'Price: Low to High';
      case WishlistSort.priceHighToLow:
        return 'Price: High to Low';
    }
  }

  List<WishlistEntry> applySort(List<WishlistEntry> entries) {
    final sorted = List<WishlistEntry>.from(entries);
    switch (sort) {
      case WishlistSort.newestFirst:
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case WishlistSort.oldestFirst:
        sorted.sort((a, b) => a.addedAt.compareTo(b.addedAt));
        break;
      case WishlistSort.priceLowToHigh:
        sorted.sort((a, b) => a.product.price.compareTo(b.product.price));
        break;
      case WishlistSort.priceHighToLow:
        sorted.sort((a, b) => b.product.price.compareTo(a.product.price));
        break;
    }
    return sorted;
  }

  Future<void> removeFromWishlist(ProductDetail product) async {
    await ref.read(wishlistNotifierProvider.notifier).toggle(product.id);
    ref.invalidate(wishlistedProductsProvider);
  }

  void openProduct(ProductDetail product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistAsync = ref.watch(wishlistedProductsProvider);

    return Scaffold(
      backgroundColor: pureWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.favorite_rounded, color: primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('Wishlist', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 22)),
                    ],
                  ),
                  PopupMenuButton<WishlistSort>(
                    onSelected: (value) => setState(() => sort = value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: WishlistSort.newestFirst, child: Text('Newest first')),
                      PopupMenuItem(value: WishlistSort.oldestFirst, child: Text('Oldest first')),
                      PopupMenuItem(value: WishlistSort.priceLowToHigh, child: Text('Price: Low to High')),
                      PopupMenuItem(value: WishlistSort.priceHighToLow, child: Text('Price: High to Low')),
                    ],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderGray),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(sortLabel, style: const TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.w600)),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: primaryGreen, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: wishlistAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: primaryGreen)),
                  error: (error, stack) => const Center(
                    child: Text('Could not load your wishlist.', style: TextStyle(color: textDark)),
                  ),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: sectionFill),
                              child: Icon(Icons.favorite_border_rounded, size: 40, color: textGray.withOpacity(0.5)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Your wishlist is empty',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Products you save will show up here.',
                              style: TextStyle(color: textGray.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      );
                    }

                    final sortedEntries = applySort(entries);

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: sortedEntries.length,
                      itemBuilder: (context, index) {
                        final entry = sortedEntries[index];
                        final product = entry.product;

                        return GestureDetector(
                          onTap: () => openProduct(product),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: pureWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderGray),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => Container(
                                      width: 72,
                                      height: 72,
                                      color: sectionFill,
                                      child: const Icon(Icons.inventory_2_outlined, color: textGray),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 15),
                                      ),
                                      if (product.brand != null) ...[
                                        const SizedBox(height: 3),
                                        Text(product.brand!, style: const TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            'Rs. ${product.price.toStringAsFixed(0)}',
                                            style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: lightGreenBg,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Eco ${product.ecoScore}',
                                              style: const TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => removeFromWishlist(product),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: lightGreenBg),
                                    child: const Icon(Icons.favorite_rounded, color: primaryGreen, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}