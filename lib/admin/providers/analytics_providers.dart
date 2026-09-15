import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class CategoryShare {
  final String category;
  final int count;
  final double percent;

  const CategoryShare({required this.category, required this.count, required this.percent});
}

class AnalyticsSnapshot {
  final int userCount;
  final int productCount;
  final int storeCount;
  final List<CategoryShare> categoryBreakdown;
  final List<Product> topRatedProducts;

  const AnalyticsSnapshot({
    required this.userCount,
    required this.productCount,
    required this.storeCount,
    required this.categoryBreakdown,
    required this.topRatedProducts,
  });
}

final analyticsSnapshotProvider = FutureProvider.autoDispose<AnalyticsSnapshot>((ref) async {
  final supabase = Supabase.instance.client;

  final results = await Future.wait<dynamic>([
    supabase.from('profiles').select().count(CountOption.exact),
    supabase.from('products').select('category'),
    supabase.from('stores').select().count(CountOption.exact),
    supabase.from('products').select().order('eco_score', ascending: false).limit(3),
  ]);

  final userCount = (results[0] as PostgrestResponse).count;
  final categoryRows = results[1] as List;
  final storeCount = (results[2] as PostgrestResponse).count;
  final topProductsRaw = results[3] as List;

  final counts = <String, int>{};
  for (final row in categoryRows) {
    final category = (row['category'] as String?)?.trim();
    final key = (category == null || category.isEmpty) ? 'Uncategorized' : category;
    counts[key] = (counts[key] ?? 0) + 1;
  }
  final total = categoryRows.length;
  final breakdown = counts.entries
      .map((e) => CategoryShare(
            category: e.key,
            count: e.value,
            percent: total == 0 ? 0 : (e.value / total) * 100,
          ))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  return AnalyticsSnapshot(
    userCount: userCount,
    productCount: categoryRows.length,
    storeCount: storeCount,
    categoryBreakdown: breakdown,
    topRatedProducts: topProductsRaw.map((e) => Product.fromMap(e)).toList(),
  );
});