import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/config/env_config.dart';
import '../../core/services/maptiler_service.dart';

class PickedLocation {
  final String address;
  final double latitude;
  final double longitude;

  const PickedLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({Key? key}) : super(key: key);

  @override
  State<PickLocationScreen> createState() => PickLocationScreenState();
}

class PickLocationScreenState extends State<PickLocationScreen> {
  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color fieldFill = Color(0xFFF3EEDD);

  final mapController = MapController();
  final searchController = TextEditingController();
  final mapTilerService = MapTilerService();

  LatLng selectedPoint = const LatLng(24.8607, 67.0011); // default: Karachi
  String? selectedAddress;
  List<LocationSuggestion> suggestions = [];
  bool isSearching = false;
  bool isResolvingAddress = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> runSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => suggestions = []);
      return;
    }
    setState(() => isSearching = true);
    final results = await mapTilerService.searchLocation(query);
    if (!mounted) return;
    setState(() {
      suggestions = results;
      isSearching = false;
    });
  }

  void selectSuggestion(LocationSuggestion suggestion) {
    final point = LatLng(suggestion.latitude, suggestion.longitude);
    setState(() {
      selectedPoint = point;
      selectedAddress = suggestion.address;
      suggestions = [];
      searchController.text = suggestion.address;
    });
    mapController.move(point, 15);
  }

  Future<void> handleMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      selectedPoint = point;
      isResolvingAddress = true;
      selectedAddress = null;
    });
    final address =
        await mapTilerService.reverseGeocode(point.latitude, point.longitude);
    if (!mounted) return;
    setState(() {
      selectedAddress = address ?? 'Pinned location';
      isResolvingAddress = false;
    });
  }

  void confirmLocation() {
    if (selectedAddress == null) return;
    Navigator.pop(
      context,
      PickedLocation(
        address: selectedAddress!,
        latitude: selectedPoint.latitude,
        longitude: selectedPoint.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkTeal),
        title: const Text(
          'Pin store location',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: runSearch,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                prefixIcon: const Icon(Icons.search, color: darkTeal),
                suffixIcon: isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined, color: vibrantGreen),
                    title: Text(
                      suggestion.address,
                      style: const TextStyle(color: darkText),
                    ),
                    onTap: () => selectSuggestion(suggestion),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: selectedPoint,
                    initialZoom: 13,
                    onTap: handleMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png'
                          '?key=${EnvConfig.mapTilerApiKey}',
                      userAgentPackageName: 'com.ecowise.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedPoint,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_pin,
                            color: vibrantGreen,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isResolvingAddress
                              ? 'Finding address...'
                              : (selectedAddress ??
                                  'Tap on the map or search above'),
                          style: const TextStyle(
                            color: darkText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: vibrantGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed:
                                selectedAddress == null ? null : confirmLocation,
                            child: const Text(
                              'Confirm location',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}