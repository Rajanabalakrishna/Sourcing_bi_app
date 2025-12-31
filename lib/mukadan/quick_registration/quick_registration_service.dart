// lib/mukadan/quick_registration/quick_registration_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../authentication/auth_service/auth_service.dart';

final String mainToken=dotenv.env['MAIN_TOKEN']!;

class quickRegistrationService {
  final String _baseUrl = 'https://supply.bharatintelligence.ai/api/mukkadam/';

  Future<Map<String, dynamic>> quickRegisterMukkadam({
    required Map<String, dynamic> mukkadamData,
  }) async {
    final Uri uri = Uri.parse('${_baseUrl}quick_register/');

    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

   // request.headers['Authorization'] = 'Token $sessionToken';

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

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)['data']};
      } else {
        final responseBody = json.decode(response.body);
        return {
          'success': false,
          'message': responseBody['error'] ?? 'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
