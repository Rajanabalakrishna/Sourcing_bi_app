import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/getTransport/transport_registration_response.dart';

class getTransportRegistrationService {
  //static const String baseUrl = "https://furtive-chrissy-reparably.ngrok-free.dev/api/user-registrations/";
  static const String baseUrl = 'https://supply.bharatintelligence.ai/api/user-registrations/';

  Future<TransportRegistrationResponse> fetchRegistrations({
    required int userId,
    required String dateFrom,
    required String dateTo,
    String entityType = "transporter", // Changed to singular as per your working URL
  }) async {
    // Constructing the URL with user_id and dates
    final url = Uri.parse("$baseUrl?user_id=$userId&entity_type=$entityType&date_from=$dateFrom&date_to=$dateTo");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return TransportRegistrationResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection error: $e");
    }
  }
}
