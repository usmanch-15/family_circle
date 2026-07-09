import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

/// Recording ke result mein file aur uski duration milti hai
class VoiceRecordResult {
  final File file;
  final int durationSeconds;
  VoiceRecordResult({required this.file, required this.durationSeconds});
}

class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  DateTime? _startedAt;
  String? _currentPath;

  bool get isRecording => _startedAt != null;

  /// Microphone permission check + recording shuru karo
  Future<bool> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 44100,
      ),
      path: path,
    );

    _startedAt   = DateTime.now();
    _currentPath = path;
    return true;
  }

  /// Recording rok kar file + duration return karo. Agar bohot chota
  /// message hai (1 second se kam) to null return hota hai.
  Future<VoiceRecordResult?> stopRecording() async {
    if (_startedAt == null) return null;

    final path = await _recorder.stop();
    final duration = DateTime.now().difference(_startedAt!).inSeconds;
    _startedAt   = null;
    _currentPath = null;

    if (path == null) return null;
    final file = File(path);
    if (!await file.exists() || duration < 1) {
      if (await file.exists()) await file.delete();
      return null;
    }

    return VoiceRecordResult(file: file, durationSeconds: duration);
  }

  /// Recording cancel karo (slide-to-cancel jaisa), file delete ho jayegi
  Future<void> cancelRecording() async {
    if (_startedAt == null) return;
    final path = await _recorder.stop();
    _startedAt   = null;
    _currentPath = null;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  /// Live amplitude stream — waveform animation ke liye
  Stream<Amplitude> get amplitudeStream =>
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 150));

  void dispose() {
    _recorder.dispose();
  }
}