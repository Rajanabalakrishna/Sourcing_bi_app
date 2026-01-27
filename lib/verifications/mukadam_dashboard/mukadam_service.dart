import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'mukkadam_data_model.dart';



class MukkadamService {
 // static const String dashboardUrl = "https://furtive-chrissy-reparably.ngrok-free.dev/api/dashboard/user";
 // static const String detailUrl = "https://furtive-chrissy-reparably.ngrok-free.dev/api/mukkadam";

  static const String dashboardUrl = "https://supply.bharatintelligence.ai/api/dashboard/user";
  static const String detailUrl = "https://supply.bharatintelligence.ai/api/mukkadam";



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


  // Fetch List
  Future<List<MukkadamDataModel>> fetchMukkadams(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    if (sessionToken == null) {
      print("Error: session_token is null in SharedPreferences");
    }

    // URL replaced with the requested verification endpoint
    final response = await http.get(
      Uri.parse('https://supply.bharatintelligence.ai/api/users/$userId/pending-verifications/?type=mukkadam&status=not_started,pending'), // https://furtive-chrissy-reparably.ngrok-free.dev
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Token $sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Updated key from 'mukkadams' to 'entities' to match the new URL response
      final List<dynamic> mukkadamList = data['entities'] ?? [];
      return mukkadamList.map((json) => MukkadamDataModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load mukkadams');
    }
  }

  // Fetch Single Detail
  Future<Map<String, dynamic>> fetchMukkadamDetails(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    final response = await http.get(
      Uri.parse('$detailUrl/$id/'),
      headers: {
        'Authorization': 'Token $sessionToken',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load details');
    }
  }

  // PATCH Update
  Future<bool> updateMukkadam(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    final response = await http.patch(
      Uri.parse('$detailUrl/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $sessionToken',
      },
      body: json.encode(data),
    );
    return response.statusCode == 200 || response.statusCode == 201;

  }
}
