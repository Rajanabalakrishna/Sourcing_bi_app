import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mukadam_bi/sqflite/local_db.dart';
import 'package:mukadam_bi/tracking%20control/location_tracker_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Audio/audio_record_handler.dart';
//import 'audio_recorder_handler.dart';
//import 'location_tracker_handler.dart';





const String notificationChannelId = 'location_tracking_channel_v9';
const int notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'Location Tracking Service',
    description: 'This service tracks location in the background.',
    importance: Importance.high, // Required for foreground services
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true, // Set to true to start on boot
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Bharat intelligence',
      initialNotificationContent: 'Active',
      foregroundServiceNotificationId: notificationId,
      // CRITICAL: This ensures the service restarts if killed
      autoStartOnBoot: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onStart,
    ),
  );
}

Timer? locationTimer; // Keep a reference to the timer


@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  print('🚀 [BACK_SERVICE] Isolate Started');

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // 1. AUTO-RESUME LOGIC
  // Check if tracking or recording was active before the app was closed
  await prefs.reload();
  await prefs.setBool('is_tracking_active', true);

  bool isAudioActive = prefs.getBool('is_audio_active') ?? false;

  void startLocationLoop() {
    if (locationTimer == null || !locationTimer!.isActive) {
      locationTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
        await LocationTrackerHandler.runLocationUpdate(service);
      });
      print("📍 Location Tracking Resumed");
    }
  }

  startLocationLoop();
  if (isAudioActive) AudioRecorderHandler.start();

  // 2. LISTENERS FOR UI COMMANDS
  service.on('startRecording').listen((event) async {
    await prefs.setBool('is_audio_active', true);
    AudioRecorderHandler.start();
  });

  service.on('stopRecording').listen((event) async {
    await prefs.setBool('is_audio_active', false);
    AudioRecorderHandler.stop();
  });

  service.on('startLocationTracking').listen((event) async {
    await prefs.setBool('is_tracking_active', true);
    startLocationLoop();
  });

  service.on('stopLocationTracking').listen((event) async {
    await prefs.setBool('is_tracking_active', false);
    locationTimer?.cancel();
    locationTimer = null;
  });

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  Timer.periodic(const Duration(seconds: 10), (timer) {
    print('💓 [HEARTBEAT] Background Service Active...');
  });

  return true;
}


