import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioRecorderHandler {
  static final AudioRecorder _audioRecorder = AudioRecorder();
  static StreamSubscription<Uint8List>? _audioSubscription;
  static List<int> _memoryBuffer = [];
  static Timer? _rotationTimer;
  static bool isRecordingActive = false;
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static const String _s3FileUploadUrl = 'https://demand.bharatintelligence.ai/chat/api/upload_image_to_s3/';
  static const String _s3AuthToken = 'e8fa8310c9af344ca22ec6bd23960d609b09c704';

  static Future<void> start() async {
    if (isRecordingActive) return;
    isRecordingActive = true;

    print('🎙️ [AUDIO_ENGINE] Initializing RAM-Stream Mode...');

    try {
      // Use 16kHz Mono for stability and lower bandwidth
      final stream = await _audioRecorder.startStream(
        const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: 16000, numChannels: 1),
      );

      _memoryBuffer.clear();
      _audioSubscription = stream.listen((Uint8List chunk) {
        _memoryBuffer.addAll(chunk);
      });

      _rotationTimer?.cancel();
      _rotationTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
        if (!isRecordingActive) return;
        if (_memoryBuffer.isEmpty) return;

        final List<int> bytesToUpload = List.from(_memoryBuffer);
        _memoryBuffer.clear();

        print('📤 [SYNC] Sending ${bytesToUpload.length} bytes from RAM to API');
        _uploadBytes(bytesToUpload);
      });

    } catch (e) {
      print('❌ [AUDIO_ENGINE] Critical Failure: $e');
      isRecordingActive = false;
    }
  }

  static Future<void> _uploadBytes(List<int> bytes) async {
    try {
      // Force reload SharedPreferences to get the latest bg_user_id from UI
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final int userId = prefs.getInt('bg_user_id') ?? 0;

      final now = DateTime.now();
      final String timestamp = DateFormat('yyyy-MM-dd/HH-mm-ss').format(now);
      final String s3Path = "supply_recordings/$userId/$timestamp/${now.millisecondsSinceEpoch}.pcm";

      FormData formData = FormData.fromMap({
        "image": MultipartFile.fromBytes(bytes, filename: "audio_chunk.pcm"),
        "name_of_image": s3Path,
      });

      print('📡 [API] POSTing to S3: $s3Path');

      final response = await _dio.post(
        _s3FileUploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Token $_s3AuthToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [API] Upload Success: $s3Path');
        // Printing the response data to see the returned URL
        print('🔗 [API] Uploaded URL/Response: ${response.data}');
      }
    } catch (e) {
      print('❌ [API] Upload Failed: $e');
    }
  }

  static void stop() async {
    print('🛑 [AUDIO_ENGINE] Stopping stream');

    if (_memoryBuffer.isNotEmpty) {
      final List<int> finalBytes = List.from(_memoryBuffer);
      print('📤 [FINAL SYNC] Sending remaining ${finalBytes.length} bytes before stopping');
      // We don't await here to avoid blocking the stop sequence,
      // but the process will start before the buffer is cleared.
      _uploadBytes(finalBytes);
    }
    isRecordingActive = false;
    _rotationTimer?.cancel();
    await _audioSubscription?.cancel();
    await _audioRecorder.stop();
    _memoryBuffer.clear();
  }
}
