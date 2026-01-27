import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mukadam_bi/transport/Transport_provider/transport_model.dart';

class TransportProviderService {
  //static const String _baseUrl = "https://furtive-chrissy-reparably.ngrok-free.dev";
  static const String _baseUrl='https://supply.bharatintelligence.ai';
  static const String _s3FileUploadUrl = 'https://demand.bharatintelligence.ai/chat/api/upload_image_to_s3/';

  // Specific S3 Auth Token added here
  static const String _s3AuthToken = 'e8fa8310c9af344ca22ec6bd23960d609b09c704';

  Future<String?> _uploadFileToS3({
    required String filePath,
    required String s3ObjectName,
    required String authToken,
  }) async {
    final uri = Uri.parse(_s3FileUploadUrl);
    final request = http.MultipartRequest('POST', uri);

    // Using the token passed to the method
    request.headers['Authorization'] = 'Token $authToken';

    String extension = p.extension(filePath).replaceFirst('.', '');
    if (extension == 'jpg') extension = 'jpeg';

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        filePath,
        filename: p.basename(filePath),
        contentType: MediaType('image', extension),
      ),
    );
    request.fields['name_of_image'] = s3ObjectName;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body);
        print('S3 Response Body: $responseBody');
        final String? key = responseBody['s3_key'] ?? responseBody['key'] ?? responseBody['path'];
        return key;
      } else {
        print('S3 Upload Failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to S3: $e');
      return null;
    }
  }

  Future<TransportProvider> createTransportProvider({
    required TransportProvider provider,
    String? profilePath,
    String? aadharPath,
    String? panPath,
    String? voterPath,
    String? dlPath,
    String? rcPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');
    if (sessionToken == null) throw Exception("Session token not found");

    final String cleanMobile = provider.contactNumber?.replaceAll(RegExp(r'\D'), '') ?? 'unknown';
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    String? profileKey, aadharKey, panKey, voterKey, dlKey, rcKey;

    // All S3 uploads now use the specific _s3AuthToken
    if (profilePath != null && profilePath.isNotEmpty) {
      profileKey = await _uploadFileToS3(
        filePath: profilePath,
        s3ObjectName: 'transport/profilephoto/$cleanMobile/profile_$timestamp${p.extension(profilePath)}',
        authToken: _s3AuthToken,
      );
    }
    if (aadharPath != null && aadharPath.isNotEmpty) {
      aadharKey = await _uploadFileToS3(
        filePath: aadharPath,
        s3ObjectName: 'transport/aadharcard/$cleanMobile/aadhar_$timestamp${p.extension(aadharPath)}',
        authToken: _s3AuthToken,
      );
    }
    if (panPath != null && panPath.isNotEmpty) {
      panKey = await _uploadFileToS3(
        filePath: panPath,
        s3ObjectName: 'transport/pancard/$cleanMobile/pan_$timestamp${p.extension(panPath)}',
        authToken: _s3AuthToken,
      );
    }
    if (voterPath != null && voterPath.isNotEmpty) {
      voterKey = await _uploadFileToS3(
        filePath: voterPath,
        s3ObjectName: 'transport/voterid/$cleanMobile/voter_$timestamp${p.extension(voterPath)}',
        authToken: _s3AuthToken,
      );
    }
    if (dlPath != null && dlPath.isNotEmpty) {
      dlKey = await _uploadFileToS3(
        filePath: dlPath,
        s3ObjectName: 'transport/drivinglicense/$cleanMobile/dl_$timestamp${p.extension(dlPath)}',
        authToken: _s3AuthToken,
      );
    }
    if (rcPath != null && rcPath.isNotEmpty) {
      rcKey = await _uploadFileToS3(
        filePath: rcPath,
        s3ObjectName: 'transport/rcbook/$cleanMobile/rc_$timestamp${p.extension(rcPath)}',
        authToken: _s3AuthToken,
      );
    }

    final finalProvider = TransportProvider(
      name: provider.name,
      contactNumber: provider.contactNumber,
      state: provider.state,
      stateCode: provider.stateCode,
      district: provider.district,
      districtCode: provider.districtCode,
      taluka: provider.taluka,
      talukaCode: provider.talukaCode,
      village: provider.village,
      villageCode: provider.villageCode,
      maxDistance: provider.maxDistance,
      isActive: provider.isActive,
      vehicleType: provider.vehicleType,
      capacity: provider.capacity,
      notes: provider.notes,
      vehicleNumber: provider.vehicleNumber,
      dlNumber: provider.dlNumber,
      driverDob: provider.driverDob,
      aadharNumber: provider.aadharNumber,
      panNumber: provider.panNumber,
      voterId: provider.voterId,
      profilePhoto: profileKey,
      aadharCard: aadharKey,
      panCard: panKey,
      voterIdCard: voterKey,
      drivingLicense: dlKey,
      rcBook: rcKey,
    );

    final response = await http.post(
      Uri.parse('$_baseUrl/api/transport-providers/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'Authorization': 'Token $sessionToken', // Backend uses sessionToken
      },
      body: jsonEncode(finalProvider.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return TransportProvider.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create transport provider: ${response.body}');
    }
  }
}
