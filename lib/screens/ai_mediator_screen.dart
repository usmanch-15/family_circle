import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../services/ai_service.dart';
import '../models/message_model.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/loading_widget.dart';

class AiMediatorScreen extends ConsumerStatefulWidget {
  const AiMediatorScreen({super.key});

  @override
  ConsumerState<AiMediatorScreen> createState() => _AiMediatorScreenState();
}

class _AiMediatorScreenState extends ConsumerState<AiMediatorScreen> {
  final _topicCtrl = TextEditingController();
  final _partyACtrl = TextEditingController();
  final _partyBCtrl = TextEditingController();
  bool _loading = false;
  String? _decision;

  Future<void> _generate() async {
    if (_topicCtrl.text.trim().isEmpty ||
        _partyACtrl.text.trim().isEmpty ||
        _partyBCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sab fields fill karein')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _decision = null;
    });

    try {
      final result = await AiService().getMediation(
        topic: _topicCtrl.text.trim(),
        partyAStatement: _partyACtrl.text.trim(),
        partyBStatement: _partyBCtrl.text.trim(),
      );
      setState(() => _decision = result);
    } catch (e) {
      setState(() => _decision = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('AI Mediator',
            style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Topic',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _topicCtrl,
              decoration: const InputDecoration(
                  hintText: 'maslan: Property Dispute'),
            ),
            const SizedBox(height: 16),
            const Text('My Side',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _partyACtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Apni baat likhein...'),
            ),
            const SizedBox(height: 16),
            const Text('Their Side',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _partyBCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Unki baat likhein...'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : _generate,
              icon: const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Mediation ho rahi hai...' : 'Generate Mediation'),
            ),
            const SizedBox(height: 20),
            if (_loading) const LoadingWidget(),
            if (_decision != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Decision',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF166534))),
                    const SizedBox(height: 8),
                    Text(_decision!,
                        style: const TextStyle(
                            color: Color(0xFF15803D), height: 1.5)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
