import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/referral/registration_response.dart';

class referralRegistrationService {
  static const String baseUrl = "https://furtive-chrissy-reparably.ngrok-free.dev/api/user-registrations/";
 // static const String baseUrl = 'https://supply.bharatintelligence.ai/api/user-registrations/';

  Future<RegistrationResponse> fetchRegistrations({
    required String username, // Changed from int userId to String username
    required String dateFrom,
    required String dateTo,
    String entityType = "mukkadams",
  }) async {
    // Constructing the URL with username and dates as per your Postman test
    final url = Uri.parse("$baseUrl?username=$username&date_from=$dateFrom&date_to=$dateTo&entity_type=$entityType");

    print("API Request URL: $url"); // Check this in your VS Code console!

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return RegistrationResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection error: $e");
    }
  }
}
