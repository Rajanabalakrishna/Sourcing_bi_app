import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingControlScreen extends StatefulWidget {
  const TrackingControlScreen({super.key});

  @override
  State<TrackingControlScreen> createState() => _TrackingControlScreenState();
}

class _TrackingControlScreenState extends State<TrackingControlScreen> {
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _loadTrackingState();
  }

  // Loads the last saved state from storage so the UI stays consistent
  Future<void> _loadTrackingState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isServiceRunning = prefs.getBool('is_tracking_active') ?? false;
    });
  }

  // This was not removed; it is essential for location services
  Future<bool> _handlePermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }

  void _toggleService() async {
    final service = FlutterBackgroundService();
    final prefs = await SharedPreferences.getInstance();
    bool isRunning = await service.isRunning();

    if (_isServiceRunning) {
      // Stop ONLY the location tracking logic in the background
      service.invoke("stopLocationTracking");
      await prefs.setBool('is_tracking_active', false);
      setState(() => _isServiceRunning = false);
      print("--- LOCATION TRACKING STOPPED ---");
    } else {
      bool hasPermission = await _handlePermissions();
      if (hasPermission) {
        // Start the background service process if it isn't running
        if (!isRunning) {
          await service.startService();
        }

        // Trigger the location loop in the background
        service.invoke("startLocationTracking");
        await prefs.setBool('is_tracking_active', true);
        setState(() => _isServiceRunning = true);
        print("--- LOCATION TRACKING STARTED ---");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("6s Location Tracker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isServiceRunning ? Icons.radar : Icons.not_interested,
              size: 100,
              color: _isServiceRunning ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _isServiceRunning ? "Tracking is Active" : "Tracking is Idle",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggleService,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isServiceRunning ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                _isServiceRunning ? "STOP TRACKING" : "START TRACKING",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
