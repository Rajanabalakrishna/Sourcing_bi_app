import "dart:convert";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

class OtpApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static final String _authToken = dotenv.env['AUTH_TOKEN']!;

  // Public global variable accessible via OtpApiService.sessionToken from any file
  static String? sessionToken;

  /// Call this in your main.dart or app initialization to load the saved token
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    sessionToken = prefs.getString('session_token');
  }

  static Future<void> mobileLogin({required String phoneNumber}) async {
    try {
      final response = await http.post(
        Uri.parse("https://furtive-chrissy-reparably.ngrok-free.dev/api/auth/mobile-login/"),
        headers: {
          "Content-Type": "application/json",
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          "mobile_number": phoneNumber,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Store in public global variable
        sessionToken = data["token"];

        // Persist to SharedPreferences so it survives app restarts
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_token', sessionToken!);

        print("User verified. Global Token: $sessionToken");
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["error"] ?? "Server returned ${response.statusCode}");
      }
    } catch (e) {
      print("Error during mobileLogin: $e");
      if (e is Exception) rethrow;
      throw Exception("Connection failed.");
    }
  }

  /// 2. Sends OTP using the static AUTH_TOKEN from .env
  static Future<void> sendOtp({required String phoneNumber}) async {
    final response = await http.post(
      Uri.parse("$_baseUrl${dotenv.env['OTP_SEND_ENDPOINT']}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Token $_authToken",
      },
      body: jsonEncode({
        "phone_number": phoneNumber,
      }),
    );

    if (response.statusCode == 200) return;

    try {
      final error = jsonDecode(response.body);
      throw Exception(error["error"] ?? "Failed to send OTP");
    } catch (_) {
      throw Exception("Server error: ${response.statusCode}");
    }
  }

  /// 3. Verifies OTP using the static AUTH_TOKEN from .env
  static Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl${dotenv.env['OTP_VERIFY_ENDPOINT']}"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Token $_authToken",
      },
      body: jsonEncode({
        "phone_number": phoneNumber,
        "otp": otp,
      }),
    );

    if (response.statusCode == 200) return true;

    try {
      final error = jsonDecode(response.body);
      throw Exception(error["error"] ?? "OTP verification failed");
    } catch (_) {
      throw Exception("Server error: ${response.statusCode}");
    }
  }
}
