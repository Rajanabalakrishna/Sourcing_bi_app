// lib/seeplan/geo_tagging_service.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Result class for geo-tagged image capture
class GeoTaggedImageResult {
  final File? imageFile;
  final Position? position;
  final String? errorMessage;
  final bool success;

  GeoTaggedImageResult({
    this.imageFile,
    this.position,
    this.errorMessage,
    required this.success,
  });

  factory GeoTaggedImageResult.success(File imageFile, Position position) {
    return GeoTaggedImageResult(
      imageFile: imageFile,
      position: position,
      success: true,
    );
  }

  factory GeoTaggedImageResult.failure(String errorMessage) {
    return GeoTaggedImageResult(
      errorMessage: errorMessage,
      success: false,
    );
  }
}

/// Service class for handling geo-tagged image capture
class GeoTaggingService {
  final ImagePicker _picker = ImagePicker();

  /// Check and request camera permission
  Future<bool> _checkCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      bool? shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: Colors.orange.shade700),
              ),
              const SizedBox(width: 12),
              const Text("Camera Permission"),
            ],
          ),
          content: const Text(
            "Camera permission is required to capture images. Please enable it from app settings.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    return false;
  }

  /// Check and request location permission
  Future<bool> _checkLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      bool? shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_off, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              const Text("Location Services"),
            ],
          ),
          content: const Text(
            "Location services are disabled. Please enable them to geo-tag your images.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      bool? shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_disabled, color: Colors.red.shade700),
              ),
              const SizedBox(width: 12),
              const Text("Location Permission"),
            ],
          ),
          content: const Text(
            "Location permission is permanently denied. Please enable it from app settings to geo-tag images.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    return true;
  }

  /// Check all required permissions
  Future<bool> checkAllPermissions(BuildContext context) async {
    bool cameraGranted = await _checkCameraPermission(context);
    if (!cameraGranted) {
      return false;
    }

    bool locationGranted = await _checkLocationPermission(context);
    if (!locationGranted) {
      return false;
    }

    return true;
  }

  /// Get current GPS position
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      debugPrint("Error getting position: $e");
      return null;
    }
  }

  /// Format coordinates for display
  String formatCoordinates(Position position) {
    return "Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}";
  }

  /// Format coordinates for watermark
  String _formatWatermarkText(Position position, DateTime timestamp) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
    return 'Lat: ${position.latitude.toStringAsFixed(6)}\n'
        'Long: ${position.longitude.toStringAsFixed(6)}\n'
        '${dateFormat.format(timestamp)}';
  }

  /// Add geo-tag watermark to image
  Future<File?> addGeoTagToImage(File imageFile, Position position) async {
    try {
      final DateTime timestamp = DateTime.now();
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode the image
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      // Create a picture recorder
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Draw the original image
      canvas.drawImage(originalImage, Offset.zero, Paint());

      // Calculate watermark position and size based on image dimensions
      final double imageWidth = originalImage.width.toDouble();
      final double imageHeight = originalImage.height.toDouble();

      // Watermark settings (bottom-left corner)
      final double fontSize = imageWidth * 0.025; // 2.5% of image width
      final double padding = imageWidth * 0.02; // 2% padding
      final double watermarkWidth = imageWidth * 0.45; // 45% of image width
      final double watermarkHeight = imageHeight * 0.12; // 12% of image height

      // Draw semi-transparent background for watermark
      final Paint bgPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      final RRect bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          padding,
          imageHeight - watermarkHeight - padding,
          watermarkWidth,
          watermarkHeight,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(bgRect, bgPaint);

      // Draw GPS icon indicator
      final Paint iconBgPaint = Paint()
        ..color = Colors.green.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(padding + fontSize * 1.2, imageHeight - watermarkHeight - padding + fontSize * 1.5),
        fontSize * 0.8,
        iconBgPaint,
      );

      // Draw watermark text
      final String watermarkText = _formatWatermarkText(position, timestamp);
      final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      )
        ..pushStyle(ui.TextStyle(color: Colors.white))
        ..addText(watermarkText);

      final ui.Paragraph paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: watermarkWidth - padding * 2));

      canvas.drawParagraph(
        paragraph,
        Offset(
          padding + fontSize * 2.5,
          imageHeight - watermarkHeight - padding + padding / 2,
        ),
      );

      // Convert to image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image watermarkedImage = await picture.toImage(
        originalImage.width,
        originalImage.height,
      );

      // Encode to bytes
      final ByteData? byteData = await watermarkedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        return null;
      }

      // Save to file
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'geotagged_${timestamp.millisecondsSinceEpoch}.png';
      final File outputFile = File(p.join(tempDir.path, fileName));
      await outputFile.writeAsBytes(byteData.buffer.asUint8List());

      // Cleanup
      originalImage.dispose();
      watermarkedImage.dispose();

      return outputFile;
    } catch (e) {
      debugPrint("Error adding geo-tag to image: $e");
      return null;
    }
  }

  /// Show image source selection dialog
  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "Select Image Source",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "GPS location will be embedded in the image",
                        style: TextStyle(fontSize: 13, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.blue.shade700),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera to capture'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.purple.shade700),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select existing photo'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick image from camera or gallery
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint("Error picking image: $e");
      return null;
    }
  }

  /// Complete flow: Check permissions → Get location → Capture image → Apply geo-tag
  Future<GeoTaggedImageResult> captureGeoTaggedImage(BuildContext context) async {
    // Step 1: Check all permissions
    bool permissionsGranted = await checkAllPermissions(context);
    if (!permissionsGranted) {
      return GeoTaggedImageResult.failure("Required permissions not granted");
    }

    // Step 2: Get current GPS position
    Position? position = await getCurrentPosition();
    if (position == null) {
      return GeoTaggedImageResult.failure("Failed to get GPS location");
    }

    // Step 3: Show image source selection
    if (!context.mounted) {
      return GeoTaggedImageResult.failure("Context not available");
    }
    ImageSource? source = await showImageSourceDialog(context);
    if (source == null) {
      return GeoTaggedImageResult.failure("Image capture cancelled");
    }

    // Step 4: Capture/Pick image
    File? originalImage = await pickImage(source);
    if (originalImage == null) {
      return GeoTaggedImageResult.failure("No image selected");
    }

    // Step 5: Apply geo-tag watermark
    File? geoTaggedImage = await addGeoTagToImage(originalImage, position);
    if (geoTaggedImage == null) {
      // If watermarking fails, return original image with position
      return GeoTaggedImageResult.success(originalImage, position);
    }

    return GeoTaggedImageResult.success(geoTaggedImage, position);
  }

  /// Capture image with pre-fetched position (useful when position is already available)
  Future<GeoTaggedImageResult> captureImageWithPosition(
      BuildContext context,
      Position position,
      ) async {
    // Check camera permission only
    bool cameraGranted = await _checkCameraPermission(context);
    if (!cameraGranted) {
      return GeoTaggedImageResult.failure("Camera permission not granted");
    }

    // Show image source selection
    if (!context.mounted) {
      return GeoTaggedImageResult.failure("Context not available");
    }
    ImageSource? source = await showImageSourceDialog(context);
    if (source == null) {
      return GeoTaggedImageResult.failure("Image capture cancelled");
    }

    // Capture/Pick image
    File? originalImage = await pickImage(source);
    if (originalImage == null) {
      return GeoTaggedImageResult.failure("No image selected");
    }

    // Apply geo-tag watermark
    File? geoTaggedImage = await addGeoTagToImage(originalImage, position);
    if (geoTaggedImage == null) {
      return GeoTaggedImageResult.success(originalImage, position);
    }

    return GeoTaggedImageResult.success(geoTaggedImage, position);
  }
}
