import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'scan_providers.dart';

SupabaseClient get _supabase => Supabase.instance.client;

// Whether the current user already has this product saved. Family
// provider keyed by productId so each product detail screen watches
// only its own status.
final isWishlistedProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, productId) async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) return false;
  try {
    final row = await _supabase
        .from('wishlist')
        .select('product_id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    return row != null;
  } catch (error) {
    debugPrint('isWishlistedProvider failed: $error');
    return false;
  }
});

class WishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  SupabaseClient get supabase => _supabase;

  Future<bool> toggle(String productId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final currentlySaved = await ref.read(isWishlistedProvider(productId).future);

    try {
      if (currentlySaved) {
        await supabase
            .from('wishlist')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', productId);
      } else {
        await supabase.from('wishlist').insert({
          'user_id': userId,
          'product_id': productId,
        });
      }
      ref.invalidate(isWishlistedProvider(productId));
      ref.invalidate(wishlistedProductsProvider);
      return !currentlySaved;
    } catch (error) {
      debugPrint('Wishlist toggle failed: $error');
      return currentlySaved;
    }
  }
}

final wishlistNotifierProvider = NotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);

// Full wishlist, for the dedicated Wishlist screen. Carries when each
// item was added, so the screen can offer real newest/oldest sorting
// instead of only whatever order the query happened to return.
class WishlistEntry {
  final ProductDetail product;
  final DateTime addedAt;

  const WishlistEntry({required this.product, required this.addedAt});
}

final wishlistedProductsProvider = FutureProvider.autoDispose<List<WishlistEntry>>((ref) async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) return [];
  try {
    final response = await _supabase
        .from('wishlist')
        .select('created_at, products(*, stores(id, name, address, phone, website, latitude, longitude))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .where((row) => row['products'] != null)
        .map((row) => WishlistEntry(
              product: ProductDetail.fromMap(row['products'] as Map<String, dynamic>),
              addedAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  } catch (error) {
    debugPrint('wishlistedProductsProvider failed: $error');
    return [];
  }
});