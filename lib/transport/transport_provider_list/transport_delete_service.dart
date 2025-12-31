


// File: lib/Transport_provider/transport_delete_service.dart

import 'package:http/http.dart' as http; // Make sure to add http to your pubspec.yaml

class TransportDeleteService {
    final String _baseUrl = 'https://supply.bharatintelligence.ai/api/transport-providers'; // Replace with your actual API base URL

  Future<void> deleteTransportProvider(int id) async {
    final url = Uri.parse('$_baseUrl/$id/');
    final headers = {'Content-Type': 'application/json'};

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 204) { // 204 No Content is common for successful DELETE
      print('Transport Provider with ID $id deleted successfully.');
    } else {
      print('Failed to delete Transport Provider with ID $id. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to delete Transport Provider: ${response.statusCode} ${response.body}');
    }
  }
}
