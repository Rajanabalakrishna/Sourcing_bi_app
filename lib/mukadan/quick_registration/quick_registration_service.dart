import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';

class quickRegistrationService {
  //static const String _baseUrl = 'https://supply.bharatintelligence.ai/api/mukkadam/';
  static const String _baseUrl = 'https://furtive-chrissy-reparably.ngrok-free.dev/api/mukkadam/';
  static const String _s3FileUploadUrl = 'https://demand.bharatintelligence.ai/chat/api/upload_image_to_s3/';

  /// Helper function to upload a single file to the dedicated S3 upload endpoint
  Future<String?> _uploadFileToS3({
    required String filePath,
    required String s3ObjectName,
    required String authToken,
  }) async {
    final uri = Uri.parse(_s3FileUploadUrl);
    final request = http.MultipartRequest('POST', uri);
    final String authTokenn = 'e8fa8310c9af344ca22ec6bd23960d609b09c704';
    // Use the authToken passed from the provider instead of a hardcoded one
    request.headers['Authorization'] = 'Token $authTokenn';
    request.headers['ngrok-skip-browser-warning'] = 'true';

    // Get file extension, handle edge cases
    String fileExtension = p.extension(filePath);
    if (fileExtension.isNotEmpty && fileExtension.startsWith('.')) {
      fileExtension = fileExtension.substring(1);
    } else {
      fileExtension = 'jpg'; // default fallback
    }

    // The S3 upload API expects the file under the 'image' field
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        filePath,
        filename: p.basename(filePath),
        contentType: MediaType('image', fileExtension),
      ),
    );

    // The S3 upload API expects the desired S3 object name under 'name_of_image'
    request.fields['name_of_image'] = s3ObjectName;

    try {
      print('📤 Uploading to S3: $s3ObjectName');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 S3 Upload Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('✅ S3 Upload successful for $s3ObjectName');
        return responseBody['s3_key'];
      } else {
        print('❌ S3 Upload failed for $s3ObjectName: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading file to S3: $e');
      return null;
    }
  }

  /// Upload all documents to S3 and return their S3 keys
  Future<Map<String, String>> _uploadDocumentsToS3({
    required String mobileNumber,
    required String authToken,
    String? profilePhotoPath,
    String? aadharCardPath,
    String? panCardPath,
    String? bankProofPath,
    String? locationCapturePath,
    String? aadharNumber,
    String? panNumber,
  }) async {
    final Map<String, String> uploadedFileS3Keys = {};
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    print('📤 Starting S3 uploads for mobile: $mobileNumber');

    // Upload Profile Photo
    if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
      final String fileExtension = p.extension(profilePhotoPath).isNotEmpty
          ? p.extension(profilePhotoPath).substring(1)
          : 'jpg';
      final String s3ObjectName = 'mukadamapp/profilephoto/$mobileNumber/profile_$timestamp.$fileExtension';

      final String? s3Key = await _uploadFileToS3(
        filePath: profilePhotoPath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );

      if (s3Key != null) {
        uploadedFileS3Keys['profile_photo_s3_key'] = s3Key;
      }
    }

    // Upload Aadhar Card
    if (aadharCardPath != null && aadharCardPath.isNotEmpty) {
      final String aadharNumberForPath = aadharNumber ?? 'unknown_aadhar';
      final String fileExtension = p.extension(aadharCardPath).isNotEmpty
          ? p.extension(aadharCardPath).substring(1)
          : 'jpg';
      final String s3ObjectName = 'mukadamapp/aadharcard/$mobileNumber/${aadharNumberForPath}_$timestamp.$fileExtension';

      final String? s3Key = await _uploadFileToS3(
        filePath: aadharCardPath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );

      if (s3Key != null) {
        uploadedFileS3Keys['aadhar_card_s3_key'] = s3Key;
      }
    }

    // Upload PAN Card
    if (panCardPath != null && panCardPath.isNotEmpty) {
      final String panNumberForPath = panNumber ?? 'unknown_pan';
      final String fileExtension = p.extension(panCardPath).isNotEmpty
          ? p.extension(panCardPath).substring(1)
          : 'jpg';
      final String s3ObjectName = 'mukadamapp/pancard/$mobileNumber/${panNumberForPath}_$timestamp.$fileExtension';

      final String? s3Key = await _uploadFileToS3(
        filePath: panCardPath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );

      if (s3Key != null) {
        uploadedFileS3Keys['pan_card_s3_key'] = s3Key;
      }
    }

    // Upload Bank Proof
    if (bankProofPath != null && bankProofPath.isNotEmpty) {
      final String fileExtension = p.extension(bankProofPath).isNotEmpty
          ? p.extension(bankProofPath).substring(1)
          : 'jpg';
      final String s3ObjectName = 'mukadamapp/bankproof/$mobileNumber/bankproof_$timestamp.$fileExtension';

      final String? s3Key = await _uploadFileToS3(
        filePath: bankProofPath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );

      if (s3Key != null) {
        uploadedFileS3Keys['bank_proof_s3_key'] = s3Key;
      }
    }

    // Upload Location Capture Photo
    if (locationCapturePath != null && locationCapturePath.isNotEmpty) {
      final String fileExtension = p.extension(locationCapturePath).isNotEmpty
          ? p.extension(locationCapturePath).substring(1)
          : 'jpg';
      final String s3ObjectName = 'mukadamapp/locationcapture/$mobileNumber/loc_$timestamp.$fileExtension';

      final String? s3Key = await _uploadFileToS3(
        filePath: locationCapturePath,
        s3ObjectName: s3ObjectName,
        authToken: authToken,
      );

      if (s3Key != null) {
        uploadedFileS3Keys['location_photo_s3_key'] = s3Key;
      }
    }

    return uploadedFileS3Keys;
  }

  /// Quick register mukkadam with S3 document uploads.
  /// The [authToken] should be passed from the UserProvider in the UI.
  Future<Map<String, dynamic>> quickRegisterMukkadam({
    required String authToken,
    required Map<String, dynamic> mukkadamData,
    String? profilePhotoPath,
    String? aadharCardPath,
    String? panCardPath,
    String? bankProofPath,
    String? locationCapturePath,
  }) async {
    final Uri uri = Uri.parse('${_baseUrl}quick_register/');

    try {
      // Step 1: Upload all documents to S3 using the authToken from provider
      print('📤 Step 1: Uploading documents to S3...');
      final String mobileNumber = mukkadamData['mobile_numbers']?.toString() ?? 'unknown';
      final String? aadharNumber = mukkadamData['aadhar_number']?.toString();
      final String? panNumber = mukkadamData['pan_number']?.toString();

      final Map<String, String> s3Keys = await _uploadDocumentsToS3(
        mobileNumber: mobileNumber,
        authToken: authToken,
        profilePhotoPath: profilePhotoPath,
        aadharCardPath: aadharCardPath,
        panCardPath: panCardPath,
        bankProofPath: bankProofPath,
        locationCapturePath: locationCapturePath,
        aadharNumber: aadharNumber,
        panNumber: panNumber,
      );

      // Check if critical uploads failed
      if (profilePhotoPath != null && !s3Keys.containsKey('profile_photo_s3_key')) {
        return {
          'success': false,
          'message': 'Failed to upload profile photo. Please check your connection.',
        };
      }

      // Step 2: Add S3 keys to mukkadam data
      final Map<String, dynamic> finalPayload = {
        ...mukkadamData,
        ...s3Keys,
      };

      // Step 3: Submit registration with S3 keys
      print('📤 Step 3: Submitting registration to backend...');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Token $authToken',
        },
        body: json.encode(finalPayload),
      );

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'logout_required': true,
        };
      }

      final responseBody = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Registration successful',
          'data': responseBody['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseBody['error'] ?? responseBody['message'] ?? 'Server Error',
        };
      }
    } catch (e) {
      print('❌ Error in quickRegisterMukkadam: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
