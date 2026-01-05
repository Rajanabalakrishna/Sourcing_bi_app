import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

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
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    final isRunning = await FlutterBackgroundService().isRunning();
    setState(() => _isServiceRunning = isRunning);
  }

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
    if (_isServiceRunning) {
      FlutterBackgroundService().invoke("stopService");
      setState(() => _isServiceRunning = false);
      print("--- TRACKING STOPPED ---");
    } else {
      bool hasPermission = await _handlePermissions();
      if (hasPermission) {
        await FlutterBackgroundService().startService();
        setState(() => _isServiceRunning = true);
        print("--- TRACKING STARTED ---");
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
              _isServiceRunning ? "Service is Active" : "Service is Idle",
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
                _isServiceRunning ? "STOP" : "START",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
