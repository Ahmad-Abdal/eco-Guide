import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../admin/models/product.dart';

/// Top products ordered by eco score — stands in for "recommendations"
/// until a real personalization/interaction-based ranking exists.
final recommendedProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('products')
      .select()
      .order('eco_score', ascending: false)
      .limit(6);
  return (data as List).map((e) => Product.fromMap(e)).toList();
});

/// User's own eco score. Returns null until the interaction-tracking
/// engine (user_product_interactions table + scoring) is built —
/// UI shows "Not calculated yet" in that case rather than a fake number.
final userEcoScoreProvider = FutureProvider.autoDispose<int?>((ref) async {
  // TODO: replace with real query once user_product_interactions +
  // scoring view exist.
  return null;
});

final userDisplayNameProvider = Provider<String?>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  final name = user?.userMetadata?['name'] as String?;
  return (name != null && name.trim().isNotEmpty) ? name.trim() : null;
});