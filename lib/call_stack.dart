import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';




class CallApiService {
 // static const String _baseUrl = "https://furtive-chrissy-reparably.ngrok-free.dev/api/calls/make/";

  static const String _baseUrl ="https://supply.bharatintelligence.ai/api/calls/make/";

  static Future<Map<String, dynamic>> makeCall({
    required String toNumber,
    required String fromNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('session_token');




      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token', // Adjust prefix (Token/Bearer) based on backend
        },
        body: jsonEncode({
          "to_number": toNumber,
          "from_number": fromNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Connection failed: $e",
      };
    }
  }
}
