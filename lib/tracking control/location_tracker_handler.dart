import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../map/location_api_service.dart';
import '../sqflite/local_db.dart';

class LocationTrackerHandler {
  static Future<void> runLocationUpdate(ServiceInstance service) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


    // 1. REFRESH DATA
    await prefs.reload();

    final dbHelper = DatabaseHelper.instance;
    final now = DateTime.now();
    final String todayDate = DateFormat('yyyy-MM-dd').format(now);
    final String currentTime = DateFormat('HH:mm:ss').format(now);
    final int? userId = prefs.getInt('bg_user_id');

    print("------------------------------------------");
    print("🔍 [DEBUG START] Time: $currentTime");
    print("👤 [DEBUG] User ID from Prefs: $userId");

    // 2. LOCATION TRACKING - ONLY BETWEEN 8:00 AM (8) AND 9:00 PM (21)
    if (now.hour >= 5 && now.hour < 22) {
      try {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        print("📍 [DEBUG] GPS Fix: ${pos.latitude}, ${pos.longitude}");
        await dbHelper.insertLocation(pos.latitude, pos.longitude, todayDate, currentTime);
        print("💾 [DEBUG] Location saved to Local DB");

        if(service is AndroidServiceInstance)
          {
            flutterLocalNotificationsPlugin.show(
              888, // Matches your notificationId
              'Bharat intelligence (Active)',
              'Last Update: $currentTime | Lat: ${pos.latitude.toStringAsFixed(4)}',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'location_tracking_channel_v9',
                  'Location Tracking Service',
                  ongoing: true,
                  importance: Importance.low,
                  priority: Priority.low,
                  icon: 'ic_bg_service_small', // Ensure this icon exists or use default
                ),
              ),
            );
          }
      } catch (e) {
        print("⚠️ [DEBUG] GPS/Storage Error: $e");
      }
    } else {
      print("🕒 [DEBUG] Outside tracking hours (8 AM - 9 PM). Skipping location capture.");
    }

    // 3. SYNC LOGIC - (Kept as per your original code)
    final int targetHour = 23;
    final int targetMinute = 00;

    final DateTime targetTime = DateTime(now.year, now.month, now.day, targetHour, targetMinute);
    final bool isTimePassed = now.isAfter(targetTime);

    print("⏰ [DEBUG] Target Sync Time: ${targetTime.hour}:${targetTime.minute}");
    print("⚖️ [DEBUG] Is current time after target? $isTimePassed");

    if (isTimePassed) {
      const String syncKey = "last_successful_sync_date";
      final String? lastSyncDate = prefs.getString(syncKey);
      print("📅 [DEBUG] Last Successful Sync Date in Prefs: $lastSyncDate");
      print("📅 [DEBUG] Today's Date: $todayDate");

      if (lastSyncDate != todayDate) {
        try {
          List<Map<String, dynamic>> localData = await dbHelper.getAllLocations();
          print("📊 [DEBUG] Records found in Local DB: ${localData.length}");

          if (localData.isNotEmpty) {
            final Map<String, dynamic> payload = {
              "user_id": userId ?? 0,
              "today_date": todayDate,
              "locations": localData.map((loc) => {
                "latitude": loc['latitude'],
                "longitude": loc['longitude'],
                "date": loc['date'],
                "time": loc['time']
              }).toList(),
            };

            print("📡 [DEBUG] HITTING API NOW...");
            await LocationApiService.postLocation(payload);

            // SUCCESS PATH
            await dbHelper.clearLocations();
            await prefs.setString(syncKey, todayDate);
            print("🚀 [DEBUG] SUCCESS! API Hitted, DB Cleared, Prefs Updated.");
          } else {
            print("ℹ️ [DEBUG] Sync skipped: Local DB is empty.");
            await prefs.setString(syncKey, todayDate);
          }
        } catch (e) {
          print("❌ [DEBUG] API HIT FAILED! Error: $e");
        }
      } else {
        print("✅ [DEBUG] Sync already completed for today.");
      }
    } else {
      final diff = targetTime.difference(now).inMinutes;
      print("⏳ [DEBUG] Waiting... Sync will trigger in $diff minutes.");
    }
    print("------------------------------------------");
  }
}
