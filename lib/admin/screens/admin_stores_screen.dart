import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_list_providers.dart';
import 'store_detail_screen.dart';
import 'add_store_screen.dart';

class AdminStoresScreen extends ConsumerWidget {
  const AdminStoresScreen({Key? key}) : super(key: key);

  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color cardFill = Color(0xFFF3EEDD);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storeListProvider);

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        elevation: 0,
        title: const Text('Stores', style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded, color: vibrantGreen),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddStoreScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: vibrantGreen,
        onRefresh: () async => ref.invalidate(storeListProvider),
        child: storesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: vibrantGreen)),
          error: (error, stack) => ListView(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Text('Could not load stores.\n$error',
                    textAlign: TextAlign.center, style: const TextStyle(color: darkText)),
              ),
            ],
          ),
          data: (stores) {
            if (stores.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.storefront_rounded, size: 48, color: darkTeal),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text('No stores yet', style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text('Tap + above to add your first store.', style: TextStyle(color: darkTeal.withOpacity(0.8))),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StoreDetailScreen(storeId: store.id)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardFill,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            store.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 64,
                              height: 64,
                              color: Colors.white,
                              child: const Icon(Icons.storefront_rounded, color: darkTeal),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(store.name,
                                  style: const TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: darkTeal),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      store.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: darkTeal, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (store.averageRating != null) ...[
                                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF2B705)),
                                    const SizedBox(width: 2),
                                    Text(store.averageRating!.toStringAsFixed(1),
                                        style: const TextStyle(color: darkText, fontWeight: FontWeight.w600, fontSize: 12)),
                                    Text(' (${store.ratingCount})',
                                        style: TextStyle(color: darkTeal.withOpacity(0.7), fontSize: 11)),
                                  ] else
                                    Text('No ratings yet',
                                        style: TextStyle(color: darkTeal.withOpacity(0.6), fontSize: 11)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.inventory_2_outlined, size: 14, color: darkTeal.withOpacity(0.7)),
                                  const SizedBox(width: 3),
                                  Text('${store.productCount} products',
                                      style: TextStyle(color: darkTeal.withOpacity(0.7), fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: darkTeal),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}