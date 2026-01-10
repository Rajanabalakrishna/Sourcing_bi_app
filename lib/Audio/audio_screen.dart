import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioRecordScreen extends StatefulWidget {
  const AudioRecordScreen({super.key});

  @override
  State<AudioRecordScreen> createState() => _AudioRecordScreenState();
}

class _AudioRecordScreenState extends State<AudioRecordScreen> {

  @override
  void initState() {
    super.initState();
    _loadAudioState();
  }
  bool isRecording = false;

  Future<void> _loadAudioState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isRecording = prefs.getBool('is_audio_active') ?? false;
    });
  }




  void toggleRecording() async{
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    final prefs = await SharedPreferences.getInstance();
    if (isRecording) {
      service.invoke("stopRecording");
      await prefs.setBool('is_audio_active', false); //
    } else {

      if (!isRunning) {
        await service.startService();
      }

      service.invoke("startRecording");
      await prefs.setBool('is_audio_active', true);
    }
    setState(() {
      isRecording = !isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Recorder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRecording ? Icons.mic : Icons.mic_none,
              size: 100,
              color: isRecording ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleRecording,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                isRecording ? "STOP RECORDING" : "START RECORDING",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
