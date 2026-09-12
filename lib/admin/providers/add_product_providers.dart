import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../../core/utils/eco_score.dart';

class AddProductState {
  final bool isSaving;
  final bool isSaved;
  final Product? savedProduct;
  final String? errorMessage;

  const AddProductState({
    this.isSaving = false,
    this.isSaved = false,
    this.savedProduct,
    this.errorMessage,
  });

  AddProductState copyWith({
    bool? isSaving,
    bool? isSaved,
    Product? savedProduct,
    String? errorMessage,
  }) =>
      AddProductState(
        isSaving: isSaving ?? this.isSaving,
        isSaved: isSaved ?? this.isSaved,
        savedProduct: savedProduct ?? this.savedProduct,
        errorMessage: errorMessage,
      );
}

class AddProductNotifier extends Notifier<AddProductState> {
  final _supabase = Supabase.instance.client;

  @override
  AddProductState build() => const AddProductState();

  Future<void> saveProduct({
    required String storeId,
    required File imageFile,
    required String name,
    String? brand,
    String? category,
    String? description,
    required double price,
    required String material,
    required String recyclable,
    required String reusable,
    required String certification,
    required String packaging,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${const Uuid().v4()}.$fileExt';
      final storagePath = 'products/$fileName';

      await _supabase.storage.from('product-images').upload(
            storagePath,
            imageFile,
          );

      final imageUrl =
          _supabase.storage.from('product-images').getPublicUrl(storagePath);

      final ecoScore = EcoScoreCalculator.calculate(
        material: material,
        reusable: reusable,
        recyclable: recyclable,
        packaging: packaging,
        certification: certification,
      );

      final product = Product(
        storeId: storeId,
        name: name,
        brand: brand,
        category: category,
        description: description,
        price: price,
        imageUrl: imageUrl,
        material: material,
        recyclable: recyclable,
        reusable: reusable,
        certification: certification,
        packaging: packaging,
        ecoScore: ecoScore,
      );

      final inserted = await _supabase
          .from('products')
          .insert(product.toMap())
          .select()
          .single();

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        savedProduct: Product.fromMap(inserted),
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isSaved: false,
        errorMessage: 'Failed to save product: $e',
      );
    }
  }
}

final addProductNotifierProvider =
    NotifierProvider.autoDispose<AddProductNotifier, AddProductState>(
  AddProductNotifier.new,
);