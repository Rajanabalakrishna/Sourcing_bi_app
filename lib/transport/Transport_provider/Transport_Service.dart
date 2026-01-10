// transport_provider_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/transport/Transport_provider/transport_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransportProviderService {
  // Using the ngrok URL for testing as per your latest request
 // static const String _baseUrl = "https://furtive-chrissy-reparably.ngrok-free.dev";
 static const String _baseUrl = 'https://supply.bharatintelligence.ai';


  Future<TransportProvider> createTransportProvider(TransportProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/transport-providers/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Token $sessionToken',
      },
      body: jsonEncode(provider.toJson()),
    );

    // Print for debugging
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return TransportProvider.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create transport provider: ${response.body}');
    }
  }
}
