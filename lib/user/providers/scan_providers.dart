import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreSummary {
  final String name;
  final String address;
  final String? phone;
  final String? website;
  final double latitude;
  final double longitude;

  const StoreSummary({
    required this.name,
    required this.address,
    this.phone,
    this.website,
    required this.latitude,
    required this.longitude,
  });

  factory StoreSummary.fromMap(Map<String, dynamic> map) {
    return StoreSummary(
      name: map['name'] as String? ?? 'Unknown store',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String?,
      website: map['website'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProductDetail {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String? brand;
  final String? category;
  final String? description;
  final String material;
  final String recyclable;
  final String reusable;
  final String certification;
  final String packaging;
  final int ecoScore;
  final StoreSummary store;

  const ProductDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.brand,
    this.category,
    this.description,
    required this.material,
    required this.recyclable,
    required this.reusable,
    required this.certification,
    required this.packaging,
    required this.ecoScore,
    required this.store,
  });

  factory ProductDetail.fromMap(Map<String, dynamic> map) {
    return ProductDetail(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Unnamed product',
      imageUrl: map['image_url'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      brand: map['brand'] as String?,
      category: map['category'] as String?,
      description: map['description'] as String?,
      material: map['material'] as String? ?? 'Unknown',
      recyclable: map['recyclable'] as String? ?? 'Unknown',
      reusable: map['reusable'] as String? ?? 'Unknown',
      certification: map['certification'] as String? ?? 'Unknown',
      packaging: map['packaging'] as String? ?? 'Unknown',
      ecoScore: (map['eco_score'] as num?)?.toInt() ?? 0,
      store: StoreSummary.fromMap(
        map['stores'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class ProductLookupState {
  final bool isLoading;
  final String? errorMessage;
  final ProductDetail? product;

  const ProductLookupState({
    this.isLoading = false,
    this.errorMessage,
    this.product,
  });

  ProductLookupState copyWith({
    bool? isLoading,
    String? errorMessage,
    ProductDetail? product,
  }) {
    return ProductLookupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      product: product,
    );
  }
}

class ProductLookupNotifier extends Notifier<ProductLookupState> {
  @override
  ProductLookupState build() => const ProductLookupState();

  SupabaseClient get supabase => Supabase.instance.client;

  Future<void> lookupProduct(String rawCode) async {
    final productId = rawCode.trim();
    if (productId.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null, product: null);
    try {
      final response = await supabase
          .from('products')
          .select('*, stores(name, address, phone, website, latitude, longitude)')
          .eq('id', productId)
          .maybeSingle();

      if (response == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No product found for this code.',
        );
        return;
      }

      // Log the scan so it counts toward the admin dashboard's Scans
      // stat. Best-effort: a logging failure shouldn't block showing
      // the product the user actually scanned.
      try {
        await supabase.from('scans').insert({'product_id': productId});
      } catch (_) {
        // Ignored — the scan itself still succeeds for the user.
      }

      state = state.copyWith(
        isLoading: false,
        product: ProductDetail.fromMap(response),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid code or product not found.',
      );
    }
  }

  void reset() {
    state = const ProductLookupState();
  }
}

final productLookupNotifierProvider =
    NotifierProvider<ProductLookupNotifier, ProductLookupState>(
  ProductLookupNotifier.new,
);