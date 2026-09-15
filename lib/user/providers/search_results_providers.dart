import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchProduct {
  final String id;
  final String name;
  final String? brand;
  final String imageUrl;
  final double price;
  final int ecoScore;

  const SearchProduct({
    required this.id,
    required this.name,
    this.brand,
    required this.imageUrl,
    required this.price,
    required this.ecoScore,
  });

  factory SearchProduct.fromMap(Map<String, dynamic> map) {
    return SearchProduct(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Unnamed product',
      brand: map['brand'] as String?,
      imageUrl: map['image_url'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      ecoScore: (map['eco_score'] as num?)?.toInt() ?? 0,
    );
  }
}

enum SortOption { relevance, priceLowToHigh, priceHighToLow, ecoScoreHighToLow }

const brandOptions = ['All', 'GreenLeaf', 'EcoKitchen', 'PureLiving', 'EcoHome', 'Other'];
const materialOptions = ['Bamboo', 'Recycled', 'Stainless Steel', 'Ceramic', 'Other'];

class FilterState {
  final RangeValues ecoScoreRange;
  final RangeValues priceRange;
  final String selectedBrand;
  final String? selectedMaterial;
  final bool inStockOnly;

  const FilterState({
    this.ecoScoreRange = const RangeValues(0, 100),
    this.priceRange = const RangeValues(0, 10000),
    this.selectedBrand = 'All',
    this.selectedMaterial,
    this.inStockOnly = true,
  });

  bool get isDefault =>
      ecoScoreRange.start == 0 &&
      ecoScoreRange.end == 100 &&
      priceRange.start == 0 &&
      priceRange.end == 10000 &&
      selectedBrand == 'All' &&
      selectedMaterial == null;

  FilterState copyWith({
    RangeValues? ecoScoreRange,
    RangeValues? priceRange,
    String? selectedBrand,
    String? selectedMaterial,
    bool clearMaterial = false,
    bool? inStockOnly,
  }) {
    return FilterState(
      ecoScoreRange: ecoScoreRange ?? this.ecoScoreRange,
      priceRange: priceRange ?? this.priceRange,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedMaterial: clearMaterial ? null : (selectedMaterial ?? this.selectedMaterial),
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }
}

SupabaseClient get supabase => Supabase.instance.client;

Future<List<SearchProduct>> fetchSearchResults({
  required String query,
  String? category,
  required FilterState filters,
  required SortOption sort,
}) async {
  try {
    var request = supabase.from('products').select();

    if (query.trim().isNotEmpty) {
      request = request.ilike('name', '%${query.trim()}%');
    }
    if (category != null && category != 'All') {
      // ilike (case-insensitive) instead of eq — protects against a
      // category value that was typed before the Category field
      // became a locked dropdown, where casing/whitespace could vary.
      request = request.ilike('category', category.trim());
    }
    if (filters.selectedBrand != 'All') {
      request = request.eq('brand', filters.selectedBrand);
    }
    if (filters.selectedMaterial != null) {
      request = request.eq('material', filters.selectedMaterial as Object);
    }
    request = request
        .gte('eco_score', filters.ecoScoreRange.start.round())
        .lte('eco_score', filters.ecoScoreRange.end.round())
        .gte('price', filters.priceRange.start)
        .lte('price', filters.priceRange.end);

    // "Relevance" doesn't sort by created_at — that column may not
    // exist on every products schema, and a missing-column error here
    // was previously being silently swallowed below, making every
    // relevance-sorted search look like "no results" instead of a
    // real failure. Sort by name instead, which every product has.
    final ordered = switch (sort) {
      SortOption.priceLowToHigh => request.order('price', ascending: true),
      SortOption.priceHighToLow => request.order('price', ascending: false),
      SortOption.ecoScoreHighToLow => request.order('eco_score', ascending: false),
      SortOption.relevance => request.order('name', ascending: true),
    };

    final response = await ordered;
    return (response as List<dynamic>)
        .map((row) => SearchProduct.fromMap(row as Map<String, dynamic>))
        .toList();
  } catch (error) {
    debugPrint('Search results query failed: $error');
    return [];
  }
}