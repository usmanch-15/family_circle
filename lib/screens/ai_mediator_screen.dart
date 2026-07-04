import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/ai_service.dart';
import '../providers/auth_provider.dart';

enum _MediatorState { chooseParty, partyA, partyAMore, partyB, partyBMore, thinking, decision }

class _Message {
  final String text;
  final String sender;
  final DateTime time;
  _Message({required this.text, required this.sender}) : time = DateTime.now();
}

class AiMediatorScreen extends ConsumerStatefulWidget {
  const AiMediatorScreen({super.key});

  @override
  ConsumerState<AiMediatorScreen> createState() => _AiMediatorScreenState();
}

class _AiMediatorScreenState extends ConsumerState<AiMediatorScreen> {
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _aiService  = AiService();

  _MediatorState _state = _MediatorState.chooseParty;
  final List<_Message> _messages = [];
  String _topic      = '';
  String _partyAName = 'Party A';
  String _partyBName = 'Party B';
  String _partyASide = '';
  String _partyBSide = '';
  bool   _loading    = false;
  String _currentParty = 'partyA';

  @override
  void initState() {
    super.initState();
    _addAiMsg('Assalam o Alaikum! Main Family Circle ka AI Mediator hun.\n\n⚖️ Main dono parties ki baat sunne ke baad fair faisla dunga.\n\nPehle batayein:\n• Party A ka naam kya hai?\n• Party B ka naam kya hai?\n• Kya masla hai (topic)?\n\nFormat: "Ali, Ahmed, ghar ka kharcha"');
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

  void _addMsg(String text, String party) {
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

    // ─── Step 0: Names + Topic ─────────────────────
      case _MediatorState.chooseParty:
        _addMsg(text, 'partyA');
        final parts = text.split(',');
        if (parts.length >= 3) {
          _partyAName = parts[0].trim();
          _partyBName = parts[1].trim();
          _topic      = parts.sublist(2).join(',').trim();
        } else if (parts.length == 2) {
          _partyAName = parts[0].trim();
          _topic      = parts[1].trim();
        } else {
          _topic = text;
        }
        await Future.delayed(const Duration(milliseconds: 500));
        _addAiMsg('Theek hai!\n\n📋 Topic: "$_topic"\n👤 Party A: $_partyAName\n👥 Party B: $_partyBName\n\n---\n\n$_partyAName, aap pehle apni baat rakho. Jo bhi masla hai poori baat likhein — koi rok tok nahi.');
        setState(() { _state = _MediatorState.partyA; _currentParty = 'partyA'; });
        break;

    // ─── Step 1: Party A baat kare ─────────────────
      case _MediatorState.partyA:
        _partyASide = text;
        _addMsg(text, 'partyA');
        await Future.delayed(const Duration(milliseconds: 500));
        _addAiMsg('Shukriya $_partyAName. Maine aapki baat note kar li.\n\nKya aur kuch kehna chahte hain? Agar haan to likhein, agar nahi to "nahi" likhein.');
        setState(() => _state = _MediatorState.partyAMore);
        break;

    // ─── Step 2: Party A aur kuch? ─────────────────
      case _MediatorState.partyAMore:
        if (_isNo(text)) {
          _addMsg(text, 'partyA');
          await Future.delayed(const Duration(milliseconds: 500));

          // Ab Party B ki turn — PHONE DOOSRE KO DO
          _showHandoffDialog(_partyBName, () {
            _addAiMsg('$_partyBName, ab aapki baat sunne ka waqt hai.\n\nJo bhi aapke dil mein hai, khul ke likhein. Koi judgment nahi hoga.');
            setState(() { _state = _MediatorState.partyB; _currentParty = 'partyB'; });
          });
        } else {
          _partyASide += '\n$text';
          _addMsg(text, 'partyA');
          await Future.delayed(const Duration(milliseconds: 500));
          _addAiMsg('Samajh gaya. Aur kuch? ("nahi" likhein agar complete ho gayi baat)');
        }
        break;

    // ─── Step 3: Party B baat kare ─────────────────
      case _MediatorState.partyB:
        _partyBSide = text;
        _addMsg(text, 'partyB');
        await Future.delayed(const Duration(milliseconds: 500));
        _addAiMsg('Shukriya $_partyBName. Maine aapki baat bhi note kar li.\n\nKya aur kuch kehna chahte hain?');
        setState(() => _state = _MediatorState.partyBMore);
        break;

    // ─── Step 4: Party B aur kuch? ─────────────────
      case _MediatorState.partyBMore:
        if (_isNo(text)) {
          _addMsg(text, 'partyB');
          await Future.delayed(const Duration(milliseconds: 500));

          // Dono complete — phone wapis pehle wale ko ya kisi bhi ko
          _showHandoffDialog('Dono Parties', () {
            _addAiMsg('Dono parties ki baatein mukammal ho gayi hain.\n\n✅ $_partyAName ki baat: noted\n✅ $_partyBName ki baat: noted\n\nKya dono AI ka fair faisla sunne ke liye tayyar hain? "haan" likhein.');
            setState(() { _state = _MediatorState.thinking; _currentParty = 'partyA'; });
          });
        } else {
          _partyBSide += '\n$text';
          _addMsg(text, 'partyB');
          await Future.delayed(const Duration(milliseconds: 500));
          _addAiMsg('Samajh gaya. Aur kuch? ("nahi" likhein)');
        }
        break;

    // ─── Step 5: Final decision ─────────────────────
      case _MediatorState.thinking:
        _addMsg(text, 'partyA');
        if (text.toLowerCase().contains('haan') || text.toLowerCase().contains('han') ||
            text.toLowerCase() == 'ha' || text.toLowerCase() == 'yes') {
          await Future.delayed(const Duration(milliseconds: 400));
          _addAiMsg('Theek hai, main dono baatein analyse kar raha hun...');
          setState(() => _loading = true);
          await _getDecision();
        } else {
          _addAiMsg('Koi baat nahi. Jab dono tayyar hon to "haan" likhein.');
        }
        break;

    // ─── After decision ─────────────────────────────
      case _MediatorState.decision:
        _addMsg(text, 'partyA');
        await Future.delayed(const Duration(milliseconds: 400));
        _addAiMsg('Agar koi sawaal ho to pooch sakte hain. Naya masla ho to "Reset" button dabayein.');
        break;

      default: break;
    }
  }

  bool _isNo(String text) {
    final t = text.toLowerCase().trim();
    return t == 'nahi' || t == 'nai' || t == 'no' || t == 'n' || t == 'na' || t.length < 4;
  }

  // ── Phone handoff dialog ────────────────────────────────
  void _showHandoffDialog(String name, VoidCallback onContinue) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.phone_android, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Phone $name ko dein',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Text(
          'Ab $name ki baari hai. Phone unhe de dein taake woh apni baat likh sakein.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              onContinue();
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Theek hai, ready hun'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getDecision() async {
    try {
      final decision = await _aiService.getMediation(
        topic:           _topic,
        partyAStatement: '$_partyAName ki baat: $_partyASide',
        partyBStatement: '$_partyBName ki baat: $_partyBSide',
      );
      setState(() { _loading = false; _state = _MediatorState.decision; });
      _addAiMsg('⚖️ AI ka Fair Faisla\nTopic: $_topic\n\n$decision\n\n─────────────────\nYeh faisla dono parties — $_partyAName aur $_partyBName — ki baatein sun kar diya gaya hai. AI ne kisi ka paksh nahi liya.');
    } catch (e) {
      setState(() => _loading = false);
      _addAiMsg('Maafi chahta hun, Claude API se rabta nahi ho saka. .env file mein CLAUDE_API_KEY check karein aur dobara "haan" likhein.');
    }
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Naya Session'),
        content: const Text('Kya aap naya mediation session shuru karna chahte hain?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _topic = _partyAName = _partyBName = _partyASide = _partyBSide = '';
                _partyAName = 'Party A';
                _partyBName = 'Party B';
                _state = _MediatorState.chooseParty;
                _currentParty = 'partyA';
              });
              _addAiMsg('Assalam o Alaikum! Naya session shuru hua.\n\nPehle batayein:\n• Party A ka naam?\n• Party B ka naam?\n• Kya masla hai?\n\nFormat: "Ali, Ahmed, ghar ka kharcha"');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String get _hintText {
    switch (_state) {
      case _MediatorState.chooseParty:  return 'Ali, Ahmed, property ka masla...';
      case _MediatorState.partyA:       return '$_partyAName: Apni baat likhein...';
      case _MediatorState.partyAMore:   return '"Nahi" ya aur baat likhein...';
      case _MediatorState.partyB:       return '$_partyBName: Apni baat likhein...';
      case _MediatorState.partyBMore:   return '"Nahi" ya aur baat likhein...';
      case _MediatorState.thinking:     return '"Haan" likhein decision ke liye...';
      case _MediatorState.decision:     return 'Koi sawaal?';
      default: return 'Likhein...';
    }
  }

  Color get _sendColor {
    if (_currentParty == 'partyB') return const Color(0xFFD97706);
    return AppColors.primary;
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
            Text(_topic.isEmpty ? 'Topic aur naam daalen' : _topic,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11), overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          // Current party indicator
          if (_state != _MediatorState.chooseParty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _currentParty == 'partyB'
                    ? const Color(0xFFD97706).withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _currentParty == 'partyB' ? _partyBName : _partyAName,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          // Party status bar
          if (_state != _MediatorState.chooseParty && _state != _MediatorState.decision)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _PartyBadge(
                    name: _partyAName,
                    color: AppColors.primary,
                    active: _currentParty == 'partyA',
                    done: _state.index >= _MediatorState.partyB.index,
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _state.index >= _MediatorState.partyB.index
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _PartyBadge(
                    name: _partyBName,
                    color: const Color(0xFFD97706),
                    active: _currentParty == 'partyB',
                    done: _state == _MediatorState.thinking || _state == _MediatorState.decision,
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (_loading && i == _messages.length) return _TypingBubble();
                return _MediatorBubble(
                  message:    _messages[i],
                  partyAName: _partyAName,
                  partyBName: _partyBName,
                );
              },
            ),
          ),

          // Input
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
                        color: _loading ? AppColors.textMuted : _sendColor,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: _sendColor.withOpacity(0.3), blurRadius: 6)],
                      ),
                      child: _loading
                          ? const Padding(padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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

class _PartyBadge extends StatelessWidget {
  final String name;
  final Color color;
  final bool active, done;
  const _PartyBadge({required this.name, required this.color, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: done ? color : active ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Icon(Icons.person, size: 14, color: active ? Colors.white : color),
        ),
        const SizedBox(width: 5),
        Text(name, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: active ? color : AppColors.textMuted)),
      ],
    );
  }
}

class _MediatorBubble extends StatelessWidget {
  final _Message message;
  final String partyAName, partyBName;
  const _MediatorBubble({required this.message, required this.partyAName, required this.partyBName});

  @override
  Widget build(BuildContext context) {
    final isAi     = message.sender == 'ai';
    final isPartyA = message.sender == 'partyA';

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
      bgColor   = AppColors.primary;
      textColor = Colors.white;
      align     = Alignment.centerRight;
      label     = '👤 $partyAName';
    } else {
      bgColor   = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
      align     = Alignment.centerLeft;
      label     = '👥 $partyBName';
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
            const Text('AI soch raha hai...', style: TextStyle(fontSize: 12, color: Color(0xFF166634))),
            const SizedBox(width: 8),
            SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF166634).withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}