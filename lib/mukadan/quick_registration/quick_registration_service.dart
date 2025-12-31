// lib/mukadan/registration/registration_Service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../authentication/auth_service/auth_service.dart';

class quickRegistrationService {
  final String _baseUrl = 'https://furtive-chrissy-reparably.ngrok-free.dev/api/mukkadam/'; // IMPORTANT: Replace with your actual API base URL

  // Existing registerMukkadam method (simplified for this context)
  Future<Map<String, dynamic>> registerMukkadam({
    required Map<String, dynamic> mukkadamData,
    String? profilePhotoPath,
    String? aadharCardPath,
    String? panCardPath,
    String? bankProofPath,
  }) async {
    // This is a placeholder. The actual implementation would handle file uploads,
    // potentially using multipart/form-data.
    // For this quick registration, we are not using these file paths.
    print('Full registration data received: $mukkadamData');
    print('File paths: $profilePhotoPath, $aadharCardPath, $panCardPath, $bankProofPath');

    // Corrected URI: removed duplicate /api/mukkadam/
    final Uri uri = Uri.parse('${_baseUrl}register/'); // Assuming full registration endpoint

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(mukkadamData),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)['data']};
      } else {
        return {'success': false, 'message': json.decode(response.body)['error'] ?? 'An error occurred'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }


  Future<Map<String, dynamic>> quickRegisterMukkadam({
    required Map<String, dynamic> mukkadamData,
  }) async {
    final Uri uri = Uri.parse('${_baseUrl}quick_register/');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // IMPORTANT: Added ngrok skip warning header
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Token ${OtpApiService.sessionToken}',
        },
        body: json.encode(mukkadamData),
      );

      // DEBUGGING: Check these in your VS Code debug console
      print('Quick Reg Status: ${response.statusCode}');
      print('Quick Reg Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)['data']};
      } else {
        // Handle cases where response might not be JSON (like ngrok errors)
        if (response.body.startsWith('<!DOCTYPE')) {
          return {'success': false, 'message': 'Ngrok error: Tunnel might be down or URL changed.'};
        }

        final responseBody = json.decode(response.body);
        return {
          'success': false,
          'message': responseBody['error'] ?? 'Server Error: ${response.statusCode}',
          'existing_mukkadam': responseBody['existing_mukkadam'],
        };
      }
    } catch (e) {
      print('Quick Reg Exception: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
