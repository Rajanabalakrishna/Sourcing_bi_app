// data_entry_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class DataEntryService {
  static const String _baseUrl = "https://supply.bharatintelligence.ai";

  /// Fetches a deduplicated list of districts from the API.
  Future<List<Map<String, dynamic>>> getDistricts() async {
    final url = Uri.parse('$_baseUrl/api/locations/districts/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }

  /// Fetches talukas belonging to a specific district.
  Future<List<Map<String, dynamic>>> getTalukas(String districtCode) async {
    final url = Uri.parse('$_baseUrl/api/locations/talukas/?district_code=$districtCode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load talukas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to the server: $e');
    }
  }
}
