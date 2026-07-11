import 'package:cloud_functions/cloud_functions.dart';

/// AI Mediator service.
///
/// SECURITY NOTE: this used to call api.anthropic.com directly from the
/// Flutter app with the Claude API key embedded in the client (readable by
/// anyone who decompiles the APK). It now calls the `askClaude` Cloud
/// Function instead — the real API key lives only on the server as a
/// Firebase Secret. See /functions/index.js.
class AiService {
  final _functions = FirebaseFunctions.instance;

  Future<String> _callClaude(String prompt, {int maxTokens = 600}) async {
    try {
      final callable = _functions.httpsCallable('askClaude');
      final result = await callable.call({
        'prompt': prompt,
        'maxTokens': maxTokens,
      });
      final text = result.data['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw 'AI se jawab nahi mila. Dobara koshish karein.';
      }
      return text;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unauthenticated') {
        throw 'Pehle login karein.';
      }
      throw 'AI Mediator se connection nahi ho saka. Internet check karein.';
    } catch (e) {
      throw 'AI Mediator se connection nahi ho saka. Internet check karein.';
    }
  }

  Future<String> getMediation({
    required String topic,
    required String partyAStatement,
    required String partyBStatement,
  }) {
    final prompt = '''
Aap ek neutral family mediator hain. Aapko Urdu mein jawab dena hai.
Topic: $topic

Party A ki baat: $partyAStatement

Party B ki baat: $partyBStatement

Dono ki baatein ghaur se sunein aur ek fair, neutral, balanced faisla dein.
Kisi ek party ko zyada favor na karein. Practical suggestion dein ke 
masla kaise hal ho sakta hai. Jawab 150 words se zyada na ho.
''';
    return _callClaude(prompt);
  }

  /// Decision ke baad koi party sawaal poochay, to yeh method use hota hai.
  /// Poora context (topic, dono statements, pehla decision) AI ko diya
  /// jata hai taake follow-up jawab consistent aur informed ho.
  Future<String> askFollowUp({
    required String topic,
    required String partyAStatement,
    required String partyBStatement,
    required String previousDecision,
    required String question,
  }) {
    final prompt = '''
Aap ek neutral family mediator hain jisne pehle ek faisla diya tha. Ab
koi party us faisle ke baare mein sawaal pooch rahi hai. Urdu mein jawab
dein, neutral rahein, aur pehle diye gaye faisle se contradict na karein
jab tak sawaal khud us faisle mein koi genuine ghalti na dikhaye.

Topic: $topic

Party A ki baat: $partyAStatement

Party B ki baat: $partyBStatement

Pehla faisla jo aapne diya tha:
$previousDecision

Ab poocha gaya sawaal: $question

Ek chota, seedha, madadgar jawab dein. 100 words se zyada na ho.
''';
    return _callClaude(prompt);
  }
}