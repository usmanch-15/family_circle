import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/constants.dart';

class AiService {
  String get _apiKey => dotenv.env['CLAUDE_API_KEY'] ?? '';

  Future<String> getMediation({
    required String topic,
    required String partyAStatement,
    required String partyBStatement,
  }) async {
    final prompt = '''
Aap ek neutral family mediator hain. Aapko Urdu mein jawab dena hai.
Topic: $topic

Party A ki baat: $partyAStatement

Party B ki baat: $partyBStatement

Dono ki baatein ghaur se sunein aur ek fair, neutral, balanced faisla dein.
Kisi ek party ko zyada favor na karein. Practical suggestion dein ke 
masla kaise hal ho sakta hai. Jawab 150 words se zyada na ho.
''';

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.claudeEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': ApiConfig.claudeModel,
          'max_tokens': ApiConfig.maxTokens,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw 'AI se jawab nahi mila. Dobara koshish karein.';
      }

      final data = jsonDecode(response.body);
      final content = data['content'] as List;
      final text = content
          .where((c) => c['type'] == 'text')
          .map((c) => c['text'] as String)
          .join('\n');

      return text;
    } catch (e) {
      throw 'AI Mediator se connection nahi ho saka. Internet check karein.';
    }
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
  }) async {
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

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.claudeEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': ApiConfig.claudeModel,
          'max_tokens': ApiConfig.maxTokens,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw 'AI se jawab nahi mila. Dobara koshish karein.';
      }

      final data = jsonDecode(response.body);
      final content = data['content'] as List;
      final text = content
          .where((c) => c['type'] == 'text')
          .map((c) => c['text'] as String)
          .join('\n');

      return text;
    } catch (e) {
      throw 'AI se connection nahi ho saka. Internet check karein.';
    }
  }
}