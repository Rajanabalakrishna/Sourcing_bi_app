import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String mainToken = dotenv.env['MAIN_TOKEN'] ?? '';

class DataEntryService {
  //static const String _baseUrl = "https://furtive-chrissy-reparably.ngrok-free.dev";

  static const String _baseUrl = "https://supply.bharatintelligence.ai";



  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }

  Future<void> createVisitPlan(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_baseUrl/api/visit-plans/');
    final token = await _getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${token ?? mainToken}',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode(payload),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to save: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getStates() async {
    final url = Uri.parse('$_baseUrl/api/locations/states/');
    final response = await http.get(url, headers: {'ngrok-skip-browser-warning': 'true'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    throw Exception('Failed to load states');
  }

  Future<List<Map<String, dynamic>>> getDistricts(String stateCode) async {
    final url = Uri.parse('$_baseUrl/api/locations/districts/?state_code=$stateCode');
    final response = await http.get(url, headers: {'ngrok-skip-browser-warning': 'true'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    throw Exception('Failed to load districts');
  }

  Future<List<Map<String, dynamic>>> getTalukas(String stateCode, String districtCode) async {
    final url = Uri.parse('$_baseUrl/api/locations/talukas/?state_code=$stateCode&district_code=$districtCode');
    final response = await http.get(url, headers: {'ngrok-skip-browser-warning': 'true'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    throw Exception('Failed to load talukas');
  }

  Future<List<Map<String, dynamic>>> getVillages(String stateCode, String talukaCode) async {
    final url = Uri.parse('$_baseUrl/api/locations/villages/?state_code=$stateCode&taluka_code=$talukaCode');
    final response = await http.get(url, headers: {'ngrok-skip-browser-warning': 'true'});
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    throw Exception('Failed to load villages');
  }
}
