import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseMsg {
  final msgService = FirebaseMessaging.instance;

  Future<void> initFCM(String userId, String mobileNumber) async {
    await msgService.requestPermission();
    String? token = await msgService.getToken();
    print("Token: $token");

    if (token != null) {
      // Send this token, userId, and mobileNumber to your Django backend
      await sendTokenToBackend(userId, mobileNumber, token);
    }

    FirebaseMessaging.onBackgroundMessage(handleNotification);
    FirebaseMessaging.onMessage.listen(handleNotification);
  }

  Future<void> sendTokenToBackend(String userId, String mobileNumber, String token) async {
    final url = Uri.parse('https://furtive-chrissy-reparably.ngrok-free.dev/api/save-fcm-token/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'mobile_number': mobileNumber,
          'fcm_token': token,
        }),
      );
      if (response.statusCode == 200) {
        print("Token and Phone Number saved to backend successfully");
      } else {
        print("Failed to save token. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending token to backend: $e");
    }
  }
}

Future<void> handleNotification(RemoteMessage msg) async {
  // Handle notification logic here
}
