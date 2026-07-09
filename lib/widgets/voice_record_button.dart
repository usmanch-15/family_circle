import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import '../utils/constants.dart';
import '../services/voice_recorder_service.dart';

/// WhatsApp jaisa hold-to-record mic button.
/// Press & hold = recording shuru, chorna = message bhej dega,
/// left ki taraf slide karna = cancel.
class VoiceRecordButton extends StatefulWidget {
  final void Function(VoiceRecordResult result) onRecorded;
  final VoidCallback? onRecordingStart;
  final VoidCallback? onRecordingEnd;

  const VoiceRecordButton({
    super.key,
    required this.onRecorded,
    this.onRecordingStart,
    this.onRecordingEnd,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> {
  final _service = VoiceRecorderService();
  bool _recording = false;
  bool _cancelZone = false;
  double _dragDx = 0;
  int _seconds = 0;
  Timer? _timer;
  double _amplitudeLevel = 0;
  StreamSubscription<Amplitude>? _ampSub;

  static const double _cancelThreshold = -90;

  Future<void> _start() async {
    final ok = await _service.startRecording();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Microphone permission chahiye voice message ke liye'),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }
    setState(() { _recording = true; _seconds = 0; _dragDx = 0; _cancelZone = false; });
    widget.onRecordingStart?.call();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
    _ampSub = _service.amplitudeStream.listen((amp) {
      final normalized = ((amp.current + 45) / 45).clamp(0.0, 1.0);
      setState(() => _amplitudeLevel = normalized);
    });
  }

  Future<void> _finish({required bool cancel}) async {
    _timer?.cancel();
    _ampSub?.cancel();
    widget.onRecordingEnd?.call();
    if (!_recording) return;
    setState(() => _recording = false);

    if (cancel) {
      await _service.cancelRecording();
      return;
    }
    final result = await _service.stopRecording();
    if (result != null) {
      widget.onRecorded(result);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampSub?.cancel();
    _service.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_recording) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (d) {
                setState(() {
                  _dragDx = (_dragDx + d.delta.dx).clamp(_cancelThreshold * 1.4, 0.0);
                  _cancelZone = _dragDx < _cancelThreshold;
                });
              },
              onHorizontalDragEnd: (_) {
                if (_cancelZone) {
                  _finish(cancel: true);
                } else {
                  setState(() => _dragDx = 0);
                }
              },
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _cancelZone
                      ? AppColors.error.withOpacity(0.1)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(_timeLabel,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(width: 10),
                    Expanded(child: _WaveformPreview(level: _amplitudeLevel)),
                    const SizedBox(width: 8),
                    Icon(
                      _cancelZone ? Icons.delete_outline : Icons.chevron_left,
                      size: 18,
                      color: _cancelZone ? AppColors.error : AppColors.textMuted,
                    ),
                    Text(
                      _cancelZone ? 'Chorein cancel karne ke liye' : 'Slide to cancel',
                      style: TextStyle(
                          fontSize: 11,
                          color: _cancelZone ? AppColors.error : AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _finish(cancel: false),
            child: Container(
              width: 42, height: 42,
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _finish(cancel: false),
      onLongPressCancel: () => _finish(cancel: true),
      child: Container(
        width: 42, height: 42,
        decoration: const BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _WaveformPreview extends StatelessWidget {
  final double level;
  const _WaveformPreview({required this.level});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(14, (i) {
          final wave = (0.3 + 0.7 * ((i % 4) / 4)) * (0.4 + level * 0.6);
          return Container(
            width: 3,
            height: (6 + wave * 14).clamp(4, 20),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}