import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map/location_api_service.dart';

const String notificationChannelId = 'location_tracking_channel_v9';
const int notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'Location Tracking Service',
    description: 'Tracking location every 6 seconds.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Tracking Active',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  Timer? trackingTimer;

  // Initialize SharedPreferences inside the isolate
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  service.on('stopService').listen((event) {
    trackingTimer?.cancel();
    service.stopSelf();
  });

  trackingTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
    final now = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(now);

    // FETCH THE ID SAVED IN MAIN
    final int userId = prefs.getInt('bg_user_id') ?? 0;

    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      final payload = {
        "user_id": userId, // Now uses the dynamic ID
        "today_date": todayDate,
        "locations": [
          {
            "latitude": pos.latitude,
            "longitude": pos.longitude
          }
        ]
      };

      await LocationApiService.postLocation(payload);

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Tracking Active",
          content: "Lat: ${pos.latitude.toStringAsFixed(4)} | Lon: ${pos.longitude.toStringAsFixed(4)}",
        );
      }

    } catch (e) {
      print("Background Error: $e");
    }
  });

  return true;
}


Future<void> _sendToApi(Map<String, dynamic> data) async {
  try {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      print("No Internet: Skipping API call");
      return;
    }

    final response = await Dio().post(
      'https://furtive-chrissy-reparably.ngrok-free.dev/api/user-locations/',
      data: data,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("API Success: Data synced successfully");
    }
  } catch (e) {
    print("API Failure: $e");
  }
}
