import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Chat bubble ke andar voice message ka player.
/// Play/pause + progress bar + duration dikhata hai.
class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final int durationSeconds;
  final bool isMe;

  const VoiceMessagePlayer({
    super.key,
    required this.audioUrl,
    required this.durationSeconds,
    required this.isMe,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final _player = AudioPlayer();
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _total = Duration(seconds: widget.durationSeconds);

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });
    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _total = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() { _playing = false; _position = Duration.zero; });
    });
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
    } else {
      if (_position == Duration.zero || _position >= _total) {
        await _player.play(UrlSource(widget.audioUrl));
      } else {
        await _player.resume();
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.isMe ? Colors.white : const Color(0xFF6C3AE8);
    final track = widget.isMe
        ? Colors.white.withOpacity(0.3)
        : const Color(0xFF6C3AE8).withOpacity(0.15);
    final progress = _total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0);

    return SizedBox(
      width: 190,
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
              child: Icon(
                _playing ? Icons.pause : Icons.play_arrow,
                size: 18,
                color: widget.isMe ? const Color(0xFF6C3AE8) : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: track,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _playing || _position > Duration.zero
                      ? _fmt(_position)
                      : _fmt(_total),
                  style: TextStyle(fontSize: 10, color: fg.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}