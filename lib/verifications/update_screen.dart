import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'mukadam_dashboard/mukadam_service.dart';

class MukkadamUpdateScreen extends StatefulWidget {
  final int mukkadamId;

  const MukkadamUpdateScreen({super.key, required this.mukkadamId});

  @override
  State<MukkadamUpdateScreen> createState() => _MukkadamUpdateScreenState();
}

class _MukkadamUpdateScreenState extends State<MukkadamUpdateScreen> {
  final MukkadamService _service = MukkadamService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _panController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _voterController = TextEditingController();
  final TextEditingController _dummyController = TextEditingController();

  Map<String, dynamic>? _data;
  bool _isLoading = true;

  String? _localPanPath;
  String? _localAadharPath;
  String? _localProfilePath;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    try {
      final data = await _service.fetchMukkadamDetails(widget.mukkadamId);
      setState(() {
        _data = data;
        _panController.text = data['pan_number'] ?? '';
        _aadharController.text = data['aadhar_number'] ?? '';
        _voterController.text = data['voter_id_number'] ?? '';
        _isLoading = false;
        _localPanPath = null;
        _localAadharPath = null;
        _localProfilePath = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 100,
      );
      if (image == null) return;

      setState(() {
        if (type == "PAN") {
          _localPanPath = image.path;
        } else if (type == "AADHAR") {
          _localAadharPath = image.path;
        } else if (type == "PROFILE") {
          _localProfilePath = image.path;
        }
      });
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _handleUpdate() async {
    setState(() => _isLoading = true);

    try {
      String? panS3Key;
      String? aadharS3Key;
      String? profileS3Key;

      final String mobileNumber = _data?['mobile_numbers'] ?? 'unknown';
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      if (_localPanPath != null) {
        final String extension = p.extension(_localPanPath!).replaceAll('.', '');
        final String pan = _panController.text.isEmpty ? "pan" : _panController.text;
        final String s3Path = "mukadamapp/pancard/$mobileNumber/${pan}_$timestamp.$extension";
        panS3Key = await _service.uploadFileToS3(filePath: _localPanPath!, s3ObjectName: s3Path);
      }

      if (_localAadharPath != null) {
        final String extension = p.extension(_localAadharPath!).replaceAll('.', '');
        final String aadhar = _aadharController.text.isEmpty ? "aadhar" : _aadharController.text;
        final String s3Path = "mukadamapp/aadharcard/$mobileNumber/${aadhar}_$timestamp.$extension";
        aadharS3Key = await _service.uploadFileToS3(filePath: _localAadharPath!, s3ObjectName: s3Path);
      }

      if (_localProfilePath != null) {
        final String extension = p.extension(_localProfilePath!).replaceAll('.', '');
        final String s3Path = "mukadamapp/profilephoto/$mobileNumber/profile_$timestamp.$extension";
        profileS3Key = await _service.uploadFileToS3(filePath: _localProfilePath!, s3ObjectName: s3Path);
      }

      final updateData = {
        "pan_number": _panController.text,
        "aadhar_number": _aadharController.text,
        "voter_id_number": _voterController.text,
        if (panS3Key != null) "pan_card_s3_key": panS3Key,
        if (aadharS3Key != null) "aadhar_card_s3_key": aadharS3Key,
        if (profileS3Key != null) "profile_photo_s3_key": profileS3Key,
      };

      bool success = await _service.updateMukkadam(widget.mukkadamId, updateData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated Successfully")));
        _loadDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update details")));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  Widget _buildVerificationSection({
    required String label,
    required bool isVerified,
    required TextEditingController controller,
    required String? networkImageUrl,
    required String? localPath,
    required String type,
    bool showTextField = true,
    bool showImagePicker = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF2D3436)),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text("Verified", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (showTextField) ...[
            TextField(
              controller: controller,
              enabled: !isVerified,
              decoration: InputDecoration(
                labelText: "$label Number",
                hintText: "Enter $label Number",
                prefixIcon: const Icon(Icons.badge_outlined),
                filled: true,
                fillColor: isVerified ? Colors.grey[100] : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (showImagePicker)
            GestureDetector(
              onTap: isVerified ? null : () => _pickImage(type),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    if (localPath != null)
                      Image.file(File(localPath), height: 180, width: double.infinity, fit: BoxFit.cover)
                    else if (networkImageUrl != null && networkImageUrl.isNotEmpty)
                      Image.network(
                        networkImageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    else
                      _buildPlaceholder(),
                    if (!isVerified)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          radius: 18,
                          child: Icon(localPath != null || (networkImageUrl?.isNotEmpty ?? false) ? Icons.edit : Icons.add_a_photo, color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.blueAccent.shade200),
          const SizedBox(height: 8),
          const Text("Upload Document", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 3)));
    }

    bool isFaceVerified = (_data?['is_face_match_verified'] ?? false) && (_data?['is_face_liveness_verified'] ?? false);
    bool isPanVerified = _data?['is_pan_verified'] ?? false;
    bool isAadharVerified = _data?['is_aadhaar_verified'] ?? false;
    bool isVoterVerified = _data?['is_voter_id_verified'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          _data?['mukkadam_name'] ?? "Update Details",
          style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildVerificationSection(
              label: "Profile Photo",
              type: "PROFILE",
              isVerified: isFaceVerified,
              controller: _dummyController,
              networkImageUrl: _data?['profile_photo_url'],
              localPath: _localProfilePath,
              showTextField: false,
            ),
            _buildVerificationSection(
              label: "PAN Card",
              type: "PAN",
              isVerified: isPanVerified,
              controller: _panController,
              networkImageUrl: _data?['pan_card_url'],
              localPath: _localPanPath,
            ),
            _buildVerificationSection(
              label: "Aadhar Card",
              type: "AADHAR",
              isVerified: isAadharVerified,
              controller: _aadharController,
              networkImageUrl: _data?['aadhar_card_url'],
              localPath: _localAadharPath,
            ),
            _buildVerificationSection(
              label: "Voter ID",
              type: "VOTER",
              isVerified: isVoterVerified,
              controller: _voterController,
              networkImageUrl: null,
              localPath: null,
              showImagePicker: false, // Image picker removed for Voter ID
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("Save & Update Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
