

// transport_provider_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/transport/Transport_provider/transport_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mukadan/authentication/auth_service/auth_service.dart';

const String API_BASE_URL = "https://supply.bharatintelligence.ai";

 final String mainToken=dotenv.env['MAIN_TOKEN']!;// Replace with your actual backend URL





class TransportProviderService {
  Future<TransportProvider> createTransportProvider(TransportProvider provider) async {

    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    // request.headers['Authorization'] = 'Token $sessionToken';
    final response = await http.post(
      Uri.parse('$API_BASE_URL/api/transport-providers/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Token $sessionToken',
      },
      body: jsonEncode(provider.toJson()),
    );

    print(response.body);

    if (response.statusCode == 201) {
      return TransportProvider.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create transport provider: ${response.body}');
    }
  }
}
