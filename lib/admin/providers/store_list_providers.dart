import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store.dart';
import '../models/product.dart';

final storeListProvider = FutureProvider.autoDispose<List<Store>>((ref) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('store_summary')
      .select()
      .order('created_at', ascending: false);
  return (data as List).map((e) => Store.fromMap(e)).toList();
});

final storeProductsProvider =
    FutureProvider.autoDispose.family<List<Product>, String>((ref, storeId) async {
  final supabase = Supabase.instance.client;
  final data = await supabase
      .from('products')
      .select()
      .eq('store_id', storeId)
      .order('created_at', ascending: false);
  return (data as List).map((e) => Product.fromMap(e)).toList();
});