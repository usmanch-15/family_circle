import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final List<String> typingUsers;
  const TypingIndicatorWidget({super.key, required this.typingUsers});

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>>   _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true));
    _anims = List.generate(3, (i) {
      Future.delayed(Duration(milliseconds: i * 150),
              () { if (mounted) _ctrls[i].repeat(reverse: true); });
      return Tween<double>(begin: 0, end: -6)
          .animate(CurvedAnimation(parent: _ctrls[i], curve: Curves.easeInOut));
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  String get _label {
    if (widget.typingUsers.isEmpty) return '';
    if (widget.typingUsers.length == 1) {
      return '${widget.typingUsers[0]} likh raha hai...';
    }
    return '${widget.typingUsers.join(', ')} likh rahe hain...';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typingUsers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(16),
                topRight:    Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft:  Radius.circular(3),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 4, offset: const Offset(0, 1))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(3, (i) => AnimatedBuilder(
                  animation: _anims[i],
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _anims[i].value),
                    child: Container(
                      width: 7, height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle),
                    ),
                  ),
                )),
                const SizedBox(width: 8),
                Text(_label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}