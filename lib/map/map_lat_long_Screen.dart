import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'location_api_service.dart'; // Import your new service

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchAndPlotLocations();
    // Auto-refresh the map every 15 seconds to show movement
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchAndPlotLocations());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAndPlotLocations() async {
    // Replace '1' with the actual logged-in user ID
    final data = await LocationApiService.getLocationHistory(1);

    if (data.isNotEmpty) {
      List<LatLng> newPoints = [];
      List<Marker> newMarkers = [];

      for (var entry in data) {
        // Adjust keys based on your API response
        final lat = entry['latitude'];
        final lng = entry['longitude'];
        if (lat != null && lng != null) {
          final point = LatLng(lat, lng);
          newPoints.add(point);
          newMarkers.add(
            Marker(
              point: point,
              width: 30,
              height: 30,
              child: const Icon(Icons.circle, color: Colors.blue, size: 12),
            ),
          );
        }
      }

      setState(() {
        _routePoints = newPoints;
        _markers = newMarkers;

        // Optionally move camera to the latest point
        if (_routePoints.isNotEmpty) {
          _mapController.move(_routePoints.last, 15.0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking Map"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAndPlotLocations)
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(0, 0),
          initialZoom: 2.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: "com.BharatIntelligence.supply_bi",
          ),
          // Draws the line connecting the points
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            ],
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
