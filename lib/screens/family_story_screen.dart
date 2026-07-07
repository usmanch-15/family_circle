import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class FamilyStoryScreen extends StatefulWidget {
  final String familyId;
  final String familyName;
  const FamilyStoryScreen(
      {super.key, required this.familyId, required this.familyName});

  @override
  State<FamilyStoryScreen> createState() => _FamilyStoryScreenState();
}

class _FamilyStoryScreenState extends State<FamilyStoryScreen> {
  bool    _loading  = false;
  String? _story;
  String? _error;

  Future<void> _generateStory() async {
    setState(() { _loading = true; _story = null; _error = null; });

    try {
      // Data collect karo
      final year = DateTime.now().year;

      // Events
      final eventsSnap = await FirebaseFirestore.instance
          .collection('events')
          .where('familyId', isEqualTo: widget.familyId)
          .where('createdAt',
          isGreaterThanOrEqualTo:
          Timestamp.fromDate(DateTime(year, 1, 1)))
          .get();

      // Messages count
      final msgsSnap = await FirebaseFirestore.instance
          .collection(Collections.families)
          .doc(widget.familyId)
          .collection(Collections.chats)
          .where('sentAt',
          isGreaterThanOrEqualTo:
          Timestamp.fromDate(DateTime(year, 1, 1)))
          .get();

      // Media count
      final mediaSnap = await FirebaseFirestore.instance
          .collection(Collections.media)
          .where('familyId', isEqualTo: widget.familyId)
          .where('uploadedAt',
          isGreaterThanOrEqualTo:
          Timestamp.fromDate(DateTime(year, 1, 1)))
          .get();

      // Events list
      final eventsList = eventsSnap.docs.map((d) {
        final data = d.data();
        return '- ${data['title']} (${data['type']})';
      }).join('\n');

      final prompt = '''
Tum ek family story writer ho. Urdu mein likho.

Family: ${widget.familyName}
Saal: $year

Is saal ki activities:
Events: ${eventsSnap.docs.length}
$eventsList

Messages: ${msgsSnap.docs.length}
Photos/Videos share: ${mediaSnap.docs.length}

Ek warm, emotional aur khubsoorat family story likho — jaise ek yearbook ka intro ho. 
150-200 words. "Is saal ${widget.familyName} ki kahani:" se shuru karo.
Family ke har member ko appreciate karo, saal ki yaadon ko celebrate karo.
''';

      final response = await http.post(
        Uri.parse(ApiConfig.claudeEndpoint),
        headers: {
          'Content-Type':    'application/json',
          'x-api-key':       const String.fromEnvironment('CLAUDE_API_KEY'),
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model':      ApiConfig.claudeModel,
          'max_tokens': 500,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data    = jsonDecode(response.body);
        final content = data['content'] as List;
        final text    = content
            .where((c) => c['type'] == 'text')
            .map((c) => c['text'] as String)
            .join('');
        setState(() => _story = text);
      } else {
        setState(() => _error = 'AI se jawab nahi mila. API key check karein.');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Family Story of the Year 📖',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C3AE8), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('📖', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.familyName} — $year',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI aapke saal bhar ke events, photos aur baatein dekh ke ek khaas family story likhega',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Generate button
            if (_story == null && !_loading)
              ElevatedButton.icon(
                onPressed: _generateStory,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  'AI se $year ki Family Story Generate Karein',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

            // Loading
            if (_loading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('AI aapki family ki kahani likh raha hai...',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],

            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.error)),
              ),

            // Story
            if (_story != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📖',
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.familyName} — $year',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      _story!,
                      style: const TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _generateStory,
                icon: const Icon(Icons.refresh),
                label: const Text('Dobara generate karein'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}