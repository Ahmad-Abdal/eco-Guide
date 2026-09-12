class Product {
  final String? id;
  final String storeId;
  final String name;
  final String? brand;
  final String? category;
  final String? description;
  final double price;
  final String imageUrl;
  final String material;
  final String recyclable;
  final String reusable;
  final String certification;
  final String packaging;
  final int ecoScore;
  final DateTime? createdAt;

  const Product({
    this.id,
    required this.storeId,
    required this.name,
    this.brand,
    this.category,
    this.description,
    required this.price,
    required this.imageUrl,
    required this.material,
    required this.recyclable,
    required this.reusable,
    required this.certification,
    required this.packaging,
    required this.ecoScore,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'store_id': storeId,
        'name': name,
        'brand': brand,
        'category': category,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'material': material,
        'recyclable': recyclable,
        'reusable': reusable,
        'certification': certification,
        'packaging': packaging,
        'eco_score': ecoScore,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        storeId: map['store_id'] as String,
        name: map['name'] as String,
        brand: map['brand'] as String?,
        category: map['category'] as String?,
        description: map['description'] as String?,
        price: (map['price'] as num).toDouble(),
        imageUrl: map['image_url'] as String,
        material: map['material'] as String,
        recyclable: map['recyclable'] as String,
        reusable: map['reusable'] as String,
        certification: map['certification'] as String,
        packaging: map['packaging'] as String,
        ecoScore: map['eco_score'] as int,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : null,
      );
}