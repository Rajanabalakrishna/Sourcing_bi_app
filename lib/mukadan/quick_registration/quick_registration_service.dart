import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class quickRegistrationService {
  // final String _baseUrl = 'https://furtive-chrissy-reparably.ngrok-free.dev/api/mukkadam/';
  static const String _baseUrl = 'https://supply.bharatintelligence.ai/api/mukkadam/';


  Future<Map<String, dynamic>> quickRegisterMukkadam({
    required Map<String, dynamic> mukkadamData,
  }) async {
    final Uri uri = Uri.parse('${_baseUrl}quick_register/');

    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Token $sessionToken',
        },
        body: json.encode(mukkadamData),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Based on your response: {"message": "...", "data": {...}}
        return {
          'success': true,
          'message': responseBody['message'],
          'data': responseBody['data']
        };
      } else {
        return {
          'success': false,
          'message': responseBody['error'] ?? responseBody['message'] ?? 'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}