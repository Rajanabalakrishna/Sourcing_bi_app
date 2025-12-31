

// File: lib/services/transport_provider_list_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Transport_provider/transport_model.dart';
// Make sure this import path matches where you have your TransportProvider model
//import 'package:your_app_name/models/transport_provider.dart';

class TransportProviderListService {
  // IMPORTANT: Replace with your actual API base URL.
  // For example: 'https://api.example.com' or 'http://10.0.2.2:8000' for Android emulator
  final String _baseUrl = "https://supply.bharatintelligence.ai";

  Future<List<TransportProvider>> fetchTransportProviders({
    String? baseLocation,
    bool? isActive,
    String? search,
    String? ordering,
  }) async {
    final Map<String, String> queryParams = {};
    if (baseLocation != null) queryParams['base_location'] = baseLocation;
    if (isActive != null) queryParams['is_active'] = isActive.toString();
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;

    final uri = Uri.parse('$_baseUrl/api/transport-providers/').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => TransportProvider.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load transport providers: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
