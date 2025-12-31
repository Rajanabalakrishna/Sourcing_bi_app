

// transport_provider_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/transport/Transport_provider/transport_model.dart';

import '../../mukadan/authentication/auth_service/auth_service.dart';

const String API_BASE_URL = "https://furtive-chrissy-reparably.ngrok-free.dev"; // Replace with your actual backend URL



class TransportProviderService {
  Future<TransportProvider> createTransportProvider(TransportProvider provider) async {
    final response = await http.post(
      Uri.parse('$API_BASE_URL/api/transport-providers/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Token ${OtpApiService.sessionToken}',
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
