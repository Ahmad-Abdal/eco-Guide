import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/nearby_stores_providers.dart';
import '../../core/config/env_config.dart';

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StoresScreen> createState() => StoresScreenState();
}

class StoresScreenState extends ConsumerState<StoresScreen> {
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color cardFill = Color(0xFFF3EEDD);

  bool showMapView = false;
  final mapController = MapController();

  Future<void> openDirections(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(nearbyStoresProvider);
    final positionAsync = ref.watch(userPositionProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: vibrantGreen, size: 22),
              const SizedBox(width: 6),
              const Text('Nearby Stores', style: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: cardFill, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Expanded(child: _toggleButton('Map View', showMapView, () => setState(() => showMapView = true))),
                Expanded(child: _toggleButton('List View', !showMapView, () => setState(() => showMapView = false))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: storesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: vibrantGreen)),
            error: (e, s) => Center(child: Text('Could not load stores.\n$e', textAlign: TextAlign.center)),
            data: (stores) {
              if (stores.isEmpty) {
                return const Center(child: Text('No stores yet.', style: TextStyle(color: darkText)));
              }
              return showMapView
                  ? _buildMapView(stores, positionAsync.value)
                  : _buildListView(stores);
            },
          ),
        ),
      ],
    );
  }

  Widget _toggleButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? vibrantGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : darkTeal,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<NearbyStore> stores) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final ns = stores[index];
        final store = ns.store;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cardFill, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      store.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.white,
                        child: const Icon(Icons.storefront_rounded, color: darkTeal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store.name, style: const TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (store.averageRating != null) ...[
                              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF2B705)),
                              const SizedBox(width: 2),
                              Text(store.averageRating!.toStringAsFixed(1),
                                  style: const TextStyle(color: darkText, fontWeight: FontWeight.w600, fontSize: 13)),
                            ] else
                              Text('New', style: TextStyle(color: darkTeal.withOpacity(0.6), fontSize: 12)),
                            if (ns.distanceKm != null) ...[
                              const SizedBox(width: 10),
                              Icon(Icons.near_me_outlined, size: 13, color: darkTeal.withOpacity(0.7)),
                              const SizedBox(width: 3),
                              Text('${ns.distanceKm!.toStringAsFixed(1)} km away',
                                  style: TextStyle(color: darkTeal.withOpacity(0.8), fontSize: 12)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: darkTeal, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => openDirections(store.latitude, store.longitude),
                      icon: const Icon(Icons.directions_rounded, size: 18, color: darkTeal),
                      label: const Text('Directions', style: TextStyle(color: darkTeal, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vibrantGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        // TODO: navigate to store detail screen (user-facing)
                      },
                      child: const Text('View Store', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<NearbyStore> stores, dynamic position) {
    final center = position != null
        ? LatLng(position.latitude, position.longitude)
        : (stores.isNotEmpty ? LatLng(stores.first.store.latitude, stores.first.store.longitude) : const LatLng(24.8607, 67.0011));

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: center, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=${EnvConfig.mapTilerApiKey}',
          userAgentPackageName: 'com.ecowise.app',
        ),
        MarkerLayer(
          markers: [
            if (position != null)
              Marker(
                point: LatLng(position.latitude, position.longitude),
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location_rounded, color: Colors.blue, size: 32),
              ),
            for (final ns in stores)
              Marker(
                point: LatLng(ns.store.latitude, ns.store.longitude),
                width: 46,
                height: 46,
                child: GestureDetector(
                  onTap: () => _showStoreSheet(ns),
                  child: const Icon(Icons.location_pin, color: vibrantGreen, size: 44),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showStoreSheet(NearbyStore ns) {
    final store = ns.store;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDF9F0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 6),
              Text(store.address, style: TextStyle(color: darkTeal.withOpacity(0.8), fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (store.averageRating != null) ...[
                    const Icon(Icons.star_rounded, color: Color(0xFFF2B705), size: 18),
                    const SizedBox(width: 4),
                    Text(store.averageRating!.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                  if (ns.distanceKm != null) ...[
                    const SizedBox(width: 12),
                    Text('${ns.distanceKm!.toStringAsFixed(1)} km away', style: TextStyle(color: darkTeal.withOpacity(0.8))),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vibrantGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    openDirections(store.latitude, store.longitude);
                  },
                  child: const Text('Get Directions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}