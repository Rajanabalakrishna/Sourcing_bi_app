// lib/registration_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/auth_service/auth_service.dart'; // For path.extension

class RegistrationService {
  // Base URL for the main Mukkadam registration endpoint
  //static const String _mukkadamRegistrationBaseUrl = 'https://supply.bharatintelligence.ai/api/mukkadam/';
  static const String _mukkadamRegistrationBaseUrl = 'https://furtive-chrissy-reparably.ngrok-free.dev/api/mukkadam/';
  // https://supply.bharatintelligence.ai/api/transport-providers/
  // Dedicated URL for uploading files directly to S3
  static const String _s3FileUploadUrl = 'https://demand.bharatintelligence.ai/chat/api/upload_image_to_s3/';

  static final String mainToken=dotenv.env['MAIN_TOKEN']!;

  // Helper function to upload a single file to the dedicated S3 upload endpoint
  Future<String?> _uploadFileToS3({
    required String filePath,
    required String s3ObjectName, // This will be the 'name_of_image' in the S3 API
    required String authToken,
  }) async {
    final uri = Uri.parse(_s3FileUploadUrl);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Token $authToken';
    // The S3 upload API expects the file under the 'image' field
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // Field name for the actual image file as expected by /upload_image_to_s3/
        filePath,
        filename: p.basename(filePath), // Original filename for the multipart part
        contentType: MediaType('image', p.extension(filePath).substring(1)),
      ),
    );
    // The S3 upload API expects the desired S3 object name under 'name_of_image'
    request.fields['name_of_image'] = s3ObjectName;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('S3 Upload successful for $s3ObjectName. Response: $responseBody');
        return responseBody['s3_key']; // Return the S3 key
      } else {
        print('S3 Upload failed for $s3ObjectName: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading file to S3: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> registerMukkadam({
    required Map<String, dynamic> mukkadamData,
    required String authToken,
    String? profilePhotoPath,
    String? aadharCardPath,
    String? panCardPath,
    String? bankProofPath,
    String? locationCapturePath,
  }) async {
    final String mobileNumber = mukkadamData['mobile_numbers'] ?? 'unknown_mobile';
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Map to store the S3 keys of all uploaded files
    final Map<String, String> uploadedFileS3Keys = {};

    // --- Step 1: Upload each file to the dedicated S3 upload endpoint ---
    print('Starting file uploads to S3...');



    if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
      final String fileExtension = p.extension(profilePhotoPath).isNotEmpty ? p.extension(profilePhotoPath).substring(1) : 'jpg';
      final String s3ObjectName = 'mukadamapp/profilephoto/${mobileNumber}/profile_${timestamp}.${fileExtension}';
      final String? s3Key = await _uploadFileToS3(
        filePath: profilePhotoPath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );
      if (s3Key != null) {
        uploadedFileS3Keys['profile_photo_s3_key'] = s3Key;
        print('- Profile Photo S3 Key: $s3Key');
      }
    }

    if (aadharCardPath != null && aadharCardPath.isNotEmpty) {
      final String aadharNumber = mukkadamData['aadhar_number'] ?? 'unknown_aadhar';
      final String fileExtension = p.extension(aadharCardPath).isNotEmpty ? p.extension(aadharCardPath).substring(1) : 'jpg';
      final String s3ObjectName = 'mukadamapp/aadharcard/${mobileNumber}/${aadharNumber}_${timestamp}.${fileExtension}';
      final String? s3Key = await _uploadFileToS3(
        filePath: aadharCardPath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );
      if (s3Key != null) {
        uploadedFileS3Keys['aadhar_card_s3_key'] = s3Key;
        print('- Aadhar Card S3 Key: $s3Key');
      }
    }
    if (panCardPath != null && panCardPath.isNotEmpty) {
      final String panNumber = mukkadamData['pan_number'] ?? 'unknown_pan';
      final String fileExtension = p.extension(panCardPath).isNotEmpty ? p.extension(panCardPath).substring(1) : 'jpg';
      final String s3ObjectName = 'mukadamapp/pancard/${mobileNumber}/${panNumber}_${timestamp}.${fileExtension}';
      final String? s3Key = await _uploadFileToS3(
        filePath: panCardPath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );
      if (s3Key != null) {
        uploadedFileS3Keys['pan_card_s3_key'] = s3Key;
        print('- PAN Card S3 Key: $s3Key');
      }
    }
    if (bankProofPath != null && bankProofPath.isNotEmpty) {
      final String fileExtension = p.extension(bankProofPath).isNotEmpty ? p.extension(bankProofPath).substring(1) : 'jpg';
      final String s3ObjectName = 'mukadamapp/bankproof/${mobileNumber}/bankproof_${timestamp}.${fileExtension}';
      final String? s3Key = await _uploadFileToS3(
        filePath: bankProofPath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );
      if (s3Key != null) {
        uploadedFileS3Keys['bank_proof_s3_key'] = s3Key;
        print('- Bank Proof S3 Key: $s3Key');
      }
    }


    if (locationCapturePath != null && locationCapturePath.isNotEmpty) {
      final String fileExtension = p
          .extension(locationCapturePath)
          .isNotEmpty
          ? p.extension(locationCapturePath).substring(1) : 'jpg';
      final String s3ObjectName = 'mukadamapp/locationcapture/${mobileNumber}/loc_${timestamp}.${fileExtension}';

      final String? s3Key = await _uploadFileToS3(
        filePath: locationCapturePath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );
      if (s3Key != null) {
        uploadedFileS3Keys['location_photo_s3_key'] = s3Key;
      }
    }





    // --- Step 2: Prepare mukkadamData with S3 keys and send to main registration endpoint ---
    // This assumes the _mukkadamRegistrationBaseUrl endpoint now expects S3 keys for files
    // (e.g., 'profile_photo_s3_key': 'mukadamApp/profilePhoto/...')
    // as part of the JSON payload, instead of receiving the raw file data directly.
    final Map<String, dynamic> finalMukkadamData = {
      ...mukkadamData, // Copy existing mukkadam data
      ...uploadedFileS3Keys, // Add the S3 keys of the uploaded files
    };

    final uri = Uri.parse(_mukkadamRegistrationBaseUrl);
    // Continue using MultipartRequest if 'data' field is still expected
    final request = http.MultipartRequest('POST', uri);

    final prefs = await SharedPreferences.getInstance();
    final String? sessionToken = prefs.getString('session_token');

    request.headers['Authorization'] = 'Token $sessionToken';
    request.headers['ngrok-skip-browser-warning'] = 'true';
    request.fields['data'] = jsonEncode(finalMukkadamData);
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('Mukkadam Registration successful. Response: ${response.body}');
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        print('Mukkadam Registration failed: ${response.statusCode} - ${response.body}');
        return {'success': false, 'message': 'Failed to register Mukkadam: ${response.statusCode} - ${response.body}'};
      }
    } catch (e) {
      print('Error sending registration request: $e');
      return {'success': false, 'message': 'Error sending registration request: $e'};
    }
  }
}
