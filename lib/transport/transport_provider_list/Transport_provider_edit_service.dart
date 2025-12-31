

// File: lib/Transport_provider/transport_provider_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http; // Make sure to add http to your pubspec.yaml

class TransportProviderServicee {
  final String _baseUrl = 'https://supply.bharatintelligence.ai/api/transport-providers'; // Replace with your actual API base URL

  Future<void> updateTransportProvider(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$id/');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(data);

    final response = await http.patch(url, headers: headers, body: body); // Using PATCH for partial update

    if (response.statusCode == 200) {
      // Successfully updated
      print('Transport Provider with ID $id updated successfully.');
    } else {
      // Handle errors
      print('Failed to update Transport Provider with ID $id. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update Transport Provider: ${response.statusCode} ${response.body}');
    }
  }

// You can add other service methods here like fetchTransportProvider, createTransportProvider, deleteTransportProvider
}
