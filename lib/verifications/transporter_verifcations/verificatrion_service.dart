import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/verifications/transporter_verifcations/verification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'pending_verification_model.dart';

class VerificationService {
  static const String baseUrl =
      "https://furtive-chrissy-reparably.ngrok-free.dev/api/users";

  Future<List<VerificationEntity>> fetchPendingVerifications(int userId) async {
    final url = Uri.parse(
      "$baseUrl/$userId/pending-verifications/?type=transporter&status=not_started,pending",
    );

    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    if (sessionToken == null) {
      print("Error: session_token is null in SharedPreferences");
    }

    try {


      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Token $sessionToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PendingVerificationResponse.fromJson(data).entities;
      } else {
        throw Exception("Failed to load verifications");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }


  // Add these methods to your existing VerificationService class

  Future<Map<String, dynamic>> fetchTransporterDetails(int transporterId) async {
    final url = Uri.parse("https://furtive-chrissy-reparably.ngrok-free.dev/api/transport-providers/$transporterId/");

    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Token $sessionToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load transporter details");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<bool> updateTransporter(int transporterId, Map<String, dynamic> data) async {
    final url = Uri.parse("https://furtive-chrissy-reparably.ngrok-free.dev/api/transport-providers/$transporterId/");

    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Token $sessionToken',
        },
        body: json.encode(data),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Update Error: $e");
      return false;
    }
  }

}
