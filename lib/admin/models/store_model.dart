class StoreModel {
  final String name;
  final String imageUrl;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String? openingHours;
  final String? description;

  const StoreModel({
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.openingHours,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image_url': imageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'opening_hours': openingHours,
      'description': description,
    };
  }
}