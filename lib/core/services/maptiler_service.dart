import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class LocationSuggestion {
  final String address;
  final double latitude;
  final double longitude;

  const LocationSuggestion({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class MapTilerService {
  List<LocationSuggestion> parseFeatures(Map<String, dynamic> data) {
    final features = data['features'] as List<dynamic>? ?? [];
    return features.map((feature) {
      final center = feature['center'] as List<dynamic>;
      return LocationSuggestion(
        address: feature['place_name'] as String? ?? '',
        longitude: (center[0] as num).toDouble(),
        latitude: (center[1] as num).toDouble(),
      );
    }).toList();
  }

  Future<List<LocationSuggestion>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];

    final baseUrl =
        'https://api.maptiler.com/geocoding/${Uri.encodeComponent(query)}.json'
        '?key=${EnvConfig.mapTilerApiKey}';

    // MapTiler excludes POIs (shops, restaurants, businesses) from the
    // default index unless explicitly requested with `types=poi`. Query
    // both the default index (addresses/places) and the POI index, then
    // merge, so searching an exact shop name actually finds the shop
    // instead of only the surrounding city/address.
    final responses = await Future.wait([
      http.get(Uri.parse(baseUrl)),
      http.get(Uri.parse('$baseUrl&types=poi')),
    ]);

    final suggestions = <LocationSuggestion>[];
    for (final response in responses) {
      if (response.statusCode != 200) continue;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      suggestions.addAll(parseFeatures(data));
    }

    final seenAddresses = <String>{};
    return suggestions.where((s) => seenAddresses.add(s.address)).toList();
  }

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.maptiler.com/geocoding/$longitude,$latitude.json'
      '?key=${EnvConfig.mapTilerApiKey}',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final suggestions = parseFeatures(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    if (suggestions.isEmpty) return null;

    return suggestions.first.address;
  }
}