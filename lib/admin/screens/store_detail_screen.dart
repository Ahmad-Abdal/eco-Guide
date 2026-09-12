import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_list_providers.dart';
import 'add_product_screen.dart';

class StoreDetailScreen extends ConsumerWidget {
  final String storeId;

  const StoreDetailScreen({Key? key, required this.storeId}) : super(key: key);

  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color cardFill = Color(0xFFF3EEDD);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storeListProvider);
    final productsAsync = ref.watch(storeProductsProvider(storeId));

    return Scaffold(
      backgroundColor: appBackground,
      body: storesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: vibrantGreen)),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (stores) {
          final store = stores.firstWhere((s) => s.id == storeId);
          return RefreshIndicator(
            color: vibrantGreen,
            onRefresh: () async {
              ref.invalidate(storeListProvider);
              ref.invalidate(storeProductsProvider(storeId));
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: appBackground,
                  expandedHeight: 220,
                  pinned: true,
                  iconTheme: const IconThemeData(color: darkTeal),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.network(
                      store.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: cardFill),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name,
                            style: const TextStyle(color: darkText, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: darkTeal),
                            const SizedBox(width: 4),
                            Expanded(child: Text(store.address, style: const TextStyle(color: darkTeal, fontSize: 13))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (store.averageRating != null) ...[
                              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF2B705)),
                              const SizedBox(width: 4),
                              Text(store.averageRating!.toStringAsFixed(1),
                                  style: const TextStyle(color: darkText, fontWeight: FontWeight.w600)),
                              Text(' (${store.ratingCount} ratings)', style: TextStyle(color: darkTeal.withOpacity(0.7), fontSize: 12)),
                            ] else
                              Text('No ratings yet', style: TextStyle(color: darkTeal.withOpacity(0.6), fontSize: 12)),
                          ],
                        ),
                        if (store.description != null) ...[
                          const SizedBox(height: 12),
                          Text(store.description!, style: const TextStyle(color: darkText, fontSize: 13)),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: vibrantGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddProductScreen(storeId: store.id, storeName: store.name),
                                ),
                              ).then((_) {
                                ref.invalidate(storeProductsProvider(storeId));
                                ref.invalidate(storeListProvider);
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Add product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Products', style: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                productsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: vibrantGreen)),
                    ),
                  ),
                  error: (e, s) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Could not load products.\n$e', style: const TextStyle(color: darkText)),
                    ),
                  ),
                  data: (products) {
                    if (products.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          child: Center(
                            child: Text('No products yet — tap "Add product" above.',
                                style: TextStyle(color: darkTeal.withOpacity(0.8))),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final p = products[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: cardFill,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1.3,
                                    child: Image.network(p.imageUrl, fit: BoxFit.cover),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: darkText, fontWeight: FontWeight.w600, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('\$${p.price.toStringAsFixed(2)}',
                                                style: const TextStyle(color: darkTeal, fontSize: 12, fontWeight: FontWeight.w600)),
                                            Row(
                                              children: [
                                                const Icon(Icons.eco_rounded, size: 13, color: vibrantGreen),
                                                const SizedBox(width: 2),
                                                Text('${p.ecoScore}',
                                                    style: const TextStyle(color: vibrantGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}