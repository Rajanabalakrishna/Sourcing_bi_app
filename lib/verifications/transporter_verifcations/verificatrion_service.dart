import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/verifications/transporter_verifcations/verification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'pending_verification_model.dart';

class VerificationService {
  //static const String baseUrl = "https://furtive-chrissy-reparably.ngrok-free.dev/api/users";

  static const String baseUrl = "https://supply.bharatintelligence.ai/api/users";



  Future<String?> uploadFileToS3({
    required String filePath,
    required String s3ObjectName,
  }) async {
    // Using the working URL and Token from your AudioRecorderHandler
    final String s3Url = "https://demand.bharatintelligence.ai/chat/api/upload_image_to_s3/";
    final String s3AuthToken = 'e8fa8310c9af344ca22ec6bd23960d609b09c704';

    final uri = Uri.parse(s3Url);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Token $s3AuthToken';
    request.headers['ngrok-skip-browser-warning'] = 'true';

    // IMPORTANT: Field names must match the working audio recorder logic
    request.fields['name_of_image'] = s3ObjectName;
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📡 [S3 DEBUG] Status: ${response.statusCode}");
      print("📡 [S3 DEBUG] Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['s3_key']; // This is the key we need for the patch
      }
      return null;
    } catch (e) {
      print("❌ S3 Upload Error: $e");
      return null;
    }
  }


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
    final url = Uri.parse("https://supply.bharatintelligence.ai/api/transport-providers/$transporterId/");

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
    final url = Uri.parse("https://supply.bharatintelligence.ai/api/transport-providers/$transporterId/");

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
