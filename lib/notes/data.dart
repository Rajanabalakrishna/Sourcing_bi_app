
// Ensure your DataEntryService handles the authorization correctly
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String mainToken=dotenv.env['MAIN_TOKEN']!;

class DataEntryService {
  static const String _baseUrl = "https://supply.bharatintelligence.ai";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }

  Future<List<Map<String, dynamic>>> getDistricts() async {
    final url = Uri.parse('$_baseUrl/api/locations/districts/');
    final response = await http.get(url, headers: {'ngrok-skip-browser-warning': 'true'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    throw Exception('Failed to load districts');
  }

  Future<List<Map<String, dynamic>>> getTalukas(String code) async {
    final url = Uri.parse('$_baseUrl/api/locations/talukas/?district_code=$code');
    final response = await http.get(url, headers: {'ngrok-skip-browser-warning': 'true'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    throw Exception('Failed to load talukas');
  }

  Future<List<Map<String, dynamic>>> getVillages(String code) async {
    final url = Uri.parse('$_baseUrl/api/locations/villages/?taluka_code=$code');
    final response = await http.get(url, headers: {'ngrok-skip-browser-warning': 'true'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    throw Exception('Failed to load villages');
  }

  Future<void> createVisitPlan(Map<String, dynamic> planData) async {
    final url = Uri.parse('$_baseUrl/api/visit-plans/');
    final token = await _getToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $mainToken',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode(planData),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Server Error: ${response.body}');
    }
  }
}