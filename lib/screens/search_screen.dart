import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/chat_model.dart';
import '../services/search_service.dart';

class SearchScreen extends StatefulWidget {
  final String familyId;
  const SearchScreen({super.key, required this.familyId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl    = TextEditingController();
  final _service = SearchService();
  List<ChatModel> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await _service.searchMessages(
          familyId: widget.familyId, query: query.trim());
      setState(() => _results = results);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Messages search karein...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: _search,
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                _ctrl.clear();
                setState(() => _results = []);
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _results.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 48,
                color: AppColors.textMuted.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              _ctrl.text.isEmpty
                  ? 'Koi bhi message search karein'
                  : 'Koi message nahi mila',
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 15),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _results.length,
        itemBuilder: (context, i) {
          final msg = _results[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.cardBg,
                      child: Text(
                        msg.senderName.isNotEmpty
                            ? msg.senderName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(msg.senderName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const Spacer(),
                    Text(Helpers.timeAgo(msg.sentAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                _HighlightedText(
                  text: msg.text ?? '',
                  query: _ctrl.text,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text, query;
  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary));
    }
    final lower    = text.toLowerCase();
    final lowerQ   = query.toLowerCase();
    final spans    = <TextSpan>[];
    int start = 0;
    int idx   = lower.indexOf(lowerQ);

    while (idx != -1) {
      if (idx > start) {
        spans.add(TextSpan(
            text: text.substring(start, idx),
            style: const TextStyle(color: AppColors.textPrimary)));
      }
      spans.add(TextSpan(
          text: text.substring(idx, idx + query.length),
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              backgroundColor: Color(0xFFEDE9FF))));
      start = idx + query.length;
      idx   = lower.indexOf(lowerQ, start);
    }
    if (start < text.length) {
      spans.add(TextSpan(
          text: text.substring(start),
          style: const TextStyle(color: AppColors.textPrimary)));
    }

    return RichText(
        text: TextSpan(
            style: const TextStyle(fontSize: 14, height: 1.4),
            children: spans));
  }
}