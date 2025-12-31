import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart'; // Added image_picker import
import 'package:mukadam_bi/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mukadam_Screen.dart';
import 'mukadan/authentication/auth_service/auth_service.dart';
import 'mukadan/registration/mukadam_registration_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await OtpApiService.init();
  await dotenv.load(fileName: ".env");

  // 2. Initialize Auth Service to load the session token from SharedPreferences




  runApp(const MyApp());

  try {
    print('Attempting to fetch location...');
    Position position = await determinePosition(); // Made public by removing underscore
    print('-------------------------');
    print('SUCCESS: GPS Coordinates Found');
    print('Latitude: ${position.latitude}');
    print('Longitude: ${position.longitude}');
    print('-------------------------');
  } catch (e) {
    print('-------------------------');
    print('LOCATION ERROR: $e');
    print('-------------------------');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mukkadam Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}

// Made this public so it can be imported into mukadam_registration_Screen.dart
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 1. Check if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // 2. Check/Request Permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  // 3. Get the current location
  return await Geolocator.getCurrentPosition();
}

// --- Section Widgets ---

class LocationCaptureSection extends StatelessWidget {
  final VoidCallback onCapture;
  final String? imagePath;
  final double? latitude;
  final double? longitude;

  const LocationCaptureSection({
    super.key,
    required this.onCapture,
    this.imagePath,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: onCapture,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Photo & Location'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade900,
            ),
          ),
          if (imagePath != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Captured: ${imagePath!.split('/').last}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (latitude != null && longitude != null) ...[
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Coordinates: $latitude, $longitude',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
