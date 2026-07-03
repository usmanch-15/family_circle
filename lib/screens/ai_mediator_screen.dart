import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/ai_service.dart';
import '../providers/auth_provider.dart';

enum _MediatorState { selectTopic, partyA, partyAMore, partyB, partyBMore, thinking, decision }

class _Message {
  final String text;
  final String sender; // 'ai', 'partyA', 'partyB'
  final DateTime time;
  _Message({required this.text, required this.sender}) : time = DateTime.now();
}

class AiMediatorScreen extends ConsumerStatefulWidget {
  const AiMediatorScreen({super.key});

  @override
  ConsumerState<AiMediatorScreen> createState() => _AiMediatorScreenState();
}

class _AiMediatorScreenState extends ConsumerState<AiMediatorScreen> {
  final _inputCtrl   = TextEditingController();
  final _scrollCtrl  = ScrollController();
  final _aiService   = AiService();

  _MediatorState _state = _MediatorState.selectTopic;
  final List<_Message> _messages = [];
  String _topic     = '';
  String _partyASide = '';
  String _partyBSide = '';
  bool _loading      = false;

  @override
  void initState() {
    super.initState();
    // First AI message
    _addAiMsg('Assalam o Alaikum! Main Family Circle ka AI Mediator hun.\n\nPehle mujhe batayein — kya masla hai? Topic likhein (maslan: ghar ka kharcha, bacho ki parhai, property)');
    _state = _MediatorState.selectTopic;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _addAiMsg(String text) {
    setState(() => _messages.add(_Message(text: text, sender: 'ai')));
    _scrollToBottom();
  }

  void _addPartyMsg(String text, String party) {
    setState(() => _messages.add(_Message(text: text, sender: party)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();

    switch (_state) {
    // ─── Topic select ──────────────────────────────
      case _MediatorState.selectTopic:
        _topic = text;
        _addPartyMsg(text, 'partyA');
        await Future.delayed(const Duration(milliseconds: 600));
        _addAiMsg('Theek hai. Topic: "$_topic"\n\nAb Party A — aap pehle apni baat rakho. Jo bhi masla hai, poori baat likhein. Koi rok tok nahi, khul ke likhein.');
        setState(() => _state = _MediatorState.partyA);
        break;

    // ─── Party A pehli baar ────────────────────────
      case _MediatorState.partyA:
        _partyASide = text;
        _addPartyMsg(text, 'partyA');
        await Future.delayed(const Duration(milliseconds: 600));
        _addAiMsg('Shukriya Party A. Maine aapki baat sun li.\n\nKya aur kuch kehna chahte hain? Ya Party B ko apni baat rakhne dein?');
        setState(() => _state = _MediatorState.partyAMore);
        break;

    // ─── Party A aur kuch kehna ────────────────────
      case _MediatorState.partyAMore:
        if (text.toLowerCase() == 'nahi' || text.toLowerCase() == 'no' || text.toLowerCase() == 'nai' || text.length < 5) {
          _addPartyMsg(text, 'partyA');
          await Future.delayed(const Duration(milliseconds: 600));
          _addAiMsg('Theek hai.\n\nAb Party B — aap apni baat rakho. Jo bhi aapke dil mein hai, bata dein. Bilkul seedha likhein.');
          setState(() => _state = _MediatorState.partyB);
        } else {
          _partyASide += '\n$text';
          _addPartyMsg(text, 'partyA');
          await Future.delayed(const Duration(milliseconds: 600));
          _addAiMsg('Samajh gaya. Koi aur baat?\n(Agar nahi to "nahi" likhein taake Party B apni baat kare)');
        }
        break;

    // ─── Party B pehli baar ────────────────────────
      case _MediatorState.partyB:
        _partyBSide = text;
        _addPartyMsg(text, 'partyB');
        await Future.delayed(const Duration(milliseconds: 600));
        _addAiMsg('Shukriya Party B. Maine aapki baat bhi sun li.\n\nKya aur kuch kehna chahte hain? Ya ab AI se decision lein?');
        setState(() => _state = _MediatorState.partyBMore);
        break;

    // ─── Party B aur kuch kehna ────────────────────
      case _MediatorState.partyBMore:
        if (text.toLowerCase() == 'nahi' || text.toLowerCase() == 'no' || text.toLowerCase() == 'nai' || text.length < 5) {
          _addPartyMsg(text, 'partyB');
          await Future.delayed(const Duration(milliseconds: 600));
          _addAiMsg('Theek hai. Dono parties ki baatein sun li hain.\n\nKya dono tayyar hain AI ka fair faisla sunne ke liye?\n\n"haan" likhein to main decision dunga.');
          setState(() => _state = _MediatorState.thinking);
        } else {
          _partyBSide += '\n$text';
          _addPartyMsg(text, 'partyB');
          await Future.delayed(const Duration(milliseconds: 600));
          _addAiMsg('Samajh gaya. Koi aur baat?\n(Agar nahi to "nahi" likhein)');
        }
        break;

    // ─── Decision lena ─────────────────────────────
      case _MediatorState.thinking:
        _addPartyMsg(text, 'partyA');
        if (text.toLowerCase().contains('haan') || text.toLowerCase().contains('han') || text.toLowerCase().contains('yes') || text.toLowerCase() == 'ha') {
          await Future.delayed(const Duration(milliseconds: 400));
          _addAiMsg('Theek hai, main dono parties ki baatein analyse kar raha hun...');
          setState(() => _loading = true);
          await _getDecision();
        } else {
          _addAiMsg('Koi baat nahi. Jab tayyar hon to "haan" likhein.');
        }
        break;

    // ─── Decision ho gaya ──────────────────────────
      case _MediatorState.decision:
        _addPartyMsg(text, 'partyA');
        await Future.delayed(const Duration(milliseconds: 400));
        _addAiMsg('Agar koi aur masla ho to naya session shuru karein — upar "Reset" button dabayein.');
        break;

      default:
        break;
    }
  }

  Future<void> _getDecision() async {
    try {
      final decision = await _aiService.getMediation(
        topic:             _topic,
        partyAStatement:   _partyASide,
        partyBStatement:   _partyBSide,
      );
      setState(() {
        _loading = false;
        _state   = _MediatorState.decision;
      });
      _addAiMsg('⚖️ AI ka Fair Faisla:\n\n$decision\n\n─────────────────\nYeh faisla dono parties ki baatein sun kar diya gaya hai. AI ne kisi ka paksh nahi liya.');
    } catch (e) {
      setState(() => _loading = false);
      _addAiMsg('Maafi chahta hun, koi masla hua. Dobara "haan" likhein.');
    }
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Naya Session'),
        content: const Text('Kya aap naya mediation session shuru karna chahte hain? Purani chat delete ho jayegi.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _topic      = '';
                _partyASide = '';
                _partyBSide = '';
                _state      = _MediatorState.selectTopic;
              });
              _addAiMsg('Assalam o Alaikum! Naya session shuru hua.\n\nKya masla hai? Topic likhein.');
            },
            child: const Text('Haan, Reset'),
          ),
        ],
      ),
    );
  }

  String get _hintText {
    switch (_state) {
      case _MediatorState.selectTopic: return 'Topic likhein...';
      case _MediatorState.partyA:     return 'Party A: Apni baat likhein...';
      case _MediatorState.partyAMore: return '"Nahi" ya aur kuch likhein...';
      case _MediatorState.partyB:     return 'Party B: Apni baat likhein...';
      case _MediatorState.partyBMore: return '"Nahi" ya aur kuch likhein...';
      case _MediatorState.thinking:   return '"Haan" likhein decision ke liye...';
      case _MediatorState.decision:   return 'Koi sawaal?';
      default: return 'Likhein...';
    }
  }

  Color get _partyColor {
    switch (_state) {
      case _MediatorState.partyA:
      case _MediatorState.partyAMore:
        return const Color(0xFF1D4ED8);
      case _MediatorState.partyB:
      case _MediatorState.partyBMore:
        return const Color(0xFFD97706);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Mediator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            Text(_topic.isEmpty ? 'Topic select karein' : _topic,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: _ProgressChip(state: _state),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          // Party labels bar
          if (_state != _MediatorState.selectTopic && _state != _MediatorState.decision)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _PartyChip(label: 'Party A', color: const Color(0xFF1D4ED8),
                      active: _state == _MediatorState.partyA || _state == _MediatorState.partyAMore),
                  const SizedBox(width: 8),
                  const Icon(Icons.compare_arrows, size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  _PartyChip(label: 'Party B', color: const Color(0xFFD97706),
                      active: _state == _MediatorState.partyB || _state == _MediatorState.partyBMore),
                  const Spacer(),
                  if (_state == _MediatorState.thinking)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Decision ready', style: TextStyle(fontSize: 11, color: Color(0xFF166534))),
                    ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (_loading && i == _messages.length) {
                  return _TypingBubble();
                }
                final msg = _messages[i];
                return _MediatorBubble(message: msg);
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        maxLines: null,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          hintText: _hintText,
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _loading ? null : _handleSend,
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _loading ? AppColors.textMuted : _partyColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6)],
                      ),
                      child: _loading
                          ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
}

// ─── Message Bubble ───────────────────────────────────────
class _MediatorBubble extends StatelessWidget {
  final _Message message;
  const _MediatorBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi     = message.sender == 'ai';
    final isPartyA = message.sender == 'partyA';
    final isPartyB = message.sender == 'partyB';

    Color bgColor;
    Color textColor;
    Alignment align;
    String label;

    if (isAi) {
      bgColor   = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF166534);
      align     = Alignment.centerLeft;
      label     = '🤖 AI Mediator';
    } else if (isPartyA) {
      bgColor   = const Color(0xFF1D4ED8);
      textColor = Colors.white;
      align     = Alignment.centerRight;
      label     = '👤 Party A';
    } else {
      bgColor   = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
      align     = Alignment.centerLeft;
      label     = '👥 Party B';
    }

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isPartyA ? 16 : 3),
            bottomRight: Radius.circular(isPartyA ? 3 : 16),
          ),
          border: isAi ? Border.all(color: const Color(0xFF86EFAC)) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor.withOpacity(0.7))),
            const SizedBox(height: 4),
            Text(message.text, style: TextStyle(fontSize: 13, color: textColor, height: 1.5)),
            const SizedBox(height: 4),
            Text(Helpers.formatTime(message.time),
                style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

// ─── Typing bubble ────────────────────────────────────────
class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFF166534)),
            const SizedBox(width: 8),
            const Text('AI soch raha hai...', style: TextStyle(fontSize: 12, color: Color(0xFF166534))),
            const SizedBox(width: 8),
            SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF166534).withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress Chip ────────────────────────────────────────
class _ProgressChip extends StatelessWidget {
  final _MediatorState state;
  const _ProgressChip({required this.state});

  String get label {
    switch (state) {
      case _MediatorState.selectTopic: return 'Topic';
      case _MediatorState.partyA:
      case _MediatorState.partyAMore:  return 'Party A';
      case _MediatorState.partyB:
      case _MediatorState.partyBMore:  return 'Party B';
      case _MediatorState.thinking:    return 'Ready';
      case _MediatorState.decision:    return 'Done ✓';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Party Chip ───────────────────────────────────────────
class _PartyChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  const _PartyChip({required this.label, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : color)),
    );
  }
}