// lib/seeplan/audio_recorder_widget.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

/// A reusable audio recorder widget with Record/Pause/Resume controls.
/// Supports multiple recordings. Max duration: 10 minutes per recording.
/// Uploads to S3 and clears local files automatically.
class AudioRecorderWidget extends StatefulWidget {
  final List<String> s3AudioKeys;
  final Future<String?> Function(String filePath, String s3ObjectName) onUpload;
  final bool enabled;

  const AudioRecorderWidget({
    super.key,
    required this.s3AudioKeys,
    required this.onUpload,
    this.enabled = true,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();

  // Recording states
  RecordingState _recordingState = RecordingState.idle;
  bool _isUploading = false;

  Timer? _timer;
  int _recordingSeconds = 0;
  static const int _maxDurationSeconds = 600; // 10 minutes

  String? _currentRecordingPath;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _cancelIfRecording();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _cancelIfRecording() async {
    try {
      if (_recordingState == RecordingState.recording ||
          _recordingState == RecordingState.paused) {
        await _recorder.stop();
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
  }

  Future<bool> _checkPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      debugPrint('Permission check error: $e');
      return false;
    }
  }

  Future<void> _startRecording() async {
    if (!widget.enabled || _isUploading || _recordingState != RecordingState.idle) return;

    bool hasPermission = await _checkPermission();
    if (!hasPermission) {
      _showMessage('Microphone permission denied / माइक परवानगी नाकारली', isError: true);
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/audio_recording_$timestamp.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _recordingState = RecordingState.recording;
        _recordingSeconds = 0;
        _currentRecordingPath = path;
      });

      _pulseController.repeat(reverse: true);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_recordingState == RecordingState.recording) {
          setState(() {
            _recordingSeconds++;
          });
          if (_recordingSeconds >= _maxDurationSeconds) {
            _stopRecording();
          }
        }
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _showMessage('Error starting recording / रेकॉर्डिंग एरर', isError: true);
    }
  }

  Future<void> _pauseRecording() async {
    if (_recordingState != RecordingState.recording) return;

    try {
      await _recorder.pause();
      _pulseController.stop();
      _pulseController.reset();

      setState(() {
        _recordingState = RecordingState.paused;
      });
    } catch (e) {
      debugPrint('Error pausing recording: $e');
      _showMessage('Error pausing / पॉज एरर', isError: true);
    }
  }

  Future<void> _resumeRecording() async {
    if (_recordingState != RecordingState.paused) return;

    try {
      await _recorder.resume();
      _pulseController.repeat(reverse: true);

      setState(() {
        _recordingState = RecordingState.recording;
      });
    } catch (e) {
      debugPrint('Error resuming recording: $e');
      _showMessage('Error resuming / पुन्हा सुरू करण्यात एरर', isError: true);
    }
  }

  Future<void> _stopRecording() async {
    if (_recordingState == RecordingState.idle) return;

    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      final path = await _recorder.stop();

      setState(() {
        _recordingState = RecordingState.idle;
      });

      if (path != null && path.isNotEmpty) {
        await _uploadAndCleanup(path);
      }
    } catch (e) {
      setState(() => _recordingState = RecordingState.idle);
      debugPrint('Error stopping recording: $e');
      _showMessage('Error stopping recording / स्टॉप एरर', isError: true);
    }
  }

  Future<void> _discardRecording() async {
    if (_recordingState == RecordingState.idle) return;

    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      final path = await _recorder.stop();

      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Recording discarded: $path');
        }
      }

      setState(() {
        _recordingState = RecordingState.idle;
        _recordingSeconds = 0;
        _currentRecordingPath = null;
      });

      _showMessage('Recording discarded / रेकॉर्डिंग रद्द केली');
    } catch (e) {
      setState(() {
        _recordingState = RecordingState.idle;
        _recordingSeconds = 0;
        _currentRecordingPath = null;
      });
      debugPrint('Error discarding recording: $e');
    }
  }

  Future<void> _uploadAndCleanup(String filePath) async {
    if (!mounted) return;
    setState(() => _isUploading = true);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = 'audio';
      final s3ObjectName = 'village-visit-audio/$userId/${timestamp}_recording.m4a';

      final s3Key = await widget.onUpload(filePath, s3ObjectName);

      if (s3Key != null && mounted) {
        setState(() {
          widget.s3AudioKeys.add(s3Key);
          _recordingSeconds = 0;
          _currentRecordingPath = null;
        });
        _showMessage('Audio uploaded! / ऑडिओ अपलोड झाला!');
      } else {
        _showMessage('Upload failed / अपलोड अयशस्वी', isError: true);
      }
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      _showMessage('Upload error / अपलोड एरर', isError: true);
    } finally {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('Local audio file deleted: $filePath');
        }
      } catch (e) {
        debugPrint('Error deleting local file: $e');
      }

      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 12)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.mic, color: Colors.indigo.shade700, size: 18),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'S3 Audio / ऑडिओ रेकॉर्डिंग',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            if (widget.s3AudioKeys.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  '${widget.s3AudioKeys.length} uploaded',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Recording Controls
        Center(
          child: Column(
            children: [
              // Main Recording Button with Animation
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _recordingState == RecordingState.recording
                        ? _pulseAnimation.value
                        : 1.0,
                    child: Container(
                      width: _recordingState != RecordingState.idle ? 88 : 68,
                      height: _recordingState != RecordingState.idle ? 88 : 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _recordingState == RecordingState.recording
                            ? Colors.red.shade400
                            : _recordingState == RecordingState.paused
                            ? Colors.orange.shade300
                            : _isUploading
                            ? Colors.orange.shade200
                            : Colors.indigo.shade50,
                        border: Border.all(
                          color: _recordingState == RecordingState.recording
                              ? Colors.red.shade600
                              : _recordingState == RecordingState.paused
                              ? Colors.orange.shade500
                              : _isUploading
                              ? Colors.orange.shade400
                              : Colors.indigo.shade200,
                          width: 3,
                        ),
                        boxShadow: _recordingState == RecordingState.recording
                            ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 16,
                            spreadRadius: 4,
                          )
                        ]
                            : _recordingState == RecordingState.paused
                            ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                            : [],
                      ),
                      child: _isUploading
                          ? const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.orange,
                          ),
                        ),
                      )
                          : Icon(
                        _recordingState == RecordingState.recording
                            ? Icons.mic
                            : _recordingState == RecordingState.paused
                            ? Icons.pause
                            : Icons.mic_none,
                        size: _recordingState != RecordingState.idle ? 36 : 28,
                        color: _recordingState != RecordingState.idle
                            ? Colors.white
                            : Colors.indigo.shade700,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Timer / Status Text
              if (_recordingState != RecordingState.idle)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _recordingState == RecordingState.recording
                        ? Colors.red.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _recordingState == RecordingState.recording
                          ? Colors.red.shade200
                          : Colors.orange.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _recordingState == RecordingState.recording
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatDuration(_recordingSeconds)} / ${_formatDuration(_maxDurationSeconds)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _recordingState == RecordingState.recording
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                )
              else if (_isUploading)
                Text(
                  'Uploading... / अपलोड होत आहे...',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                )
              else
                Text(
                  'Tap to start recording / रेकॉर्ड करण्यासाठी टॅप करा',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 16),

              // Control Buttons
              if (_recordingState == RecordingState.idle && !_isUploading)
                ElevatedButton.icon(
                  onPressed: widget.enabled ? _startRecording : null,
                  icon: const Icon(Icons.fiber_manual_record, size: 20),
                  label: const Text('Start Recording / सुरू करा'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else if (_recordingState == RecordingState.recording)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pause Button
                    ElevatedButton.icon(
                      onPressed: _pauseRecording,
                      icon: const Icon(Icons.pause, size: 20),
                      label: const Text('Pause / पॉज'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Stop & Save Button
                    ElevatedButton.icon(
                      onPressed: _stopRecording,
                      icon: const Icon(Icons.stop, size: 20),
                      label: const Text('Save / सेव्ह'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Discard Button
                    IconButton(
                      onPressed: _discardRecording,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade600,
                      iconSize: 28,
                      tooltip: 'Discard / रद्द करा',
                    ),
                  ],
                )
              else if (_recordingState == RecordingState.paused)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Resume Button
                      ElevatedButton.icon(
                        onPressed: _resumeRecording,
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text('Resume / पुन्हा सुरू'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Stop & Save Button
                      ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: const Icon(Icons.stop, size: 20),
                        label: const Text('Save / सेव्ह'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Discard Button
                      IconButton(
                        onPressed: _discardRecording,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade600,
                        iconSize: 28,
                        tooltip: 'Discard / रद्द करा',
                      ),
                    ],
                  ),
            ],
          ),
        ),

        // Uploaded Recordings List
        if (widget.s3AudioKeys.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Uploaded / अपलोड केलेले:',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...widget.s3AudioKeys.asMap().entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.audio_file, color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Recording ${entry.key + 1} / रेकॉर्डिंग ${entry.key + 1}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.cloud_done, color: Colors.green.shade700, size: 18),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

enum RecordingState {
  idle,
  recording,
  paused,
}
