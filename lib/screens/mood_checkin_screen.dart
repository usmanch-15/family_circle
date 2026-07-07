import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class MoodCheckinScreen extends ConsumerStatefulWidget {
  final String familyId;
  const MoodCheckinScreen({super.key, required this.familyId});

  @override
  ConsumerState<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends ConsumerState<MoodCheckinScreen> {
  final _noteCtrl = TextEditingController();
  String _selectedEmoji = '😊';
  bool _loading = false;

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Khush'},
    {'emoji': '😢', 'label': 'Udaas'},
    {'emoji': '😡', 'label': 'Pareshan'},
    {'emoji': '😴', 'label': 'Thaka'},
    {'emoji': '🤒', 'label': 'Beemar'},
    {'emoji': '🥰', 'label': 'Pyaar'},
    {'emoji': '😎', 'label': 'Mast'},
    {'emoji': '🙏', 'label': 'Shukar'},
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection(Collections.families)
          .doc(widget.familyId)
          .collection('mood_checkins')
          .add({
        'uid':       user.uid,
        'name':      user.name,
        'emoji':     _selectedEmoji,
        'note':      _noteCtrl.text.trim(),
        'createdAt': Timestamp.now(),
        'date':      DateTime.now().toIso8601String().substring(0, 10),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood share ho gaya! ✅'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
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
        title: const Text('Aaj Kaisa Din Tha?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C3AE8), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(_selectedEmoji,
                      style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 8),
                  Text(
                    _moods.firstWhere(
                            (m) => m['emoji'] == _selectedEmoji)['label']!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Mood chunein',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _moods.map((mood) {
                final selected = _selectedEmoji == mood['emoji'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedEmoji = mood['emoji']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood['emoji']!,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text(mood['label']!,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Kuch kehna hai? (optional)',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                hintText: 'Aaj kuch khaas tha? Share karo family ke sath...',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Text('Family ke sath Share Karein',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            const Text('Aaj ki Family Moods',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(Collections.families)
                  .doc(widget.familyId)
                  .collection('mood_checkins')
                  .where('date',
                  isEqualTo: DateTime.now()
                      .toIso8601String()
                      .substring(0, 10))
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text('Abhi kisi ne mood share nahi kiya',
                        style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Text(data['emoji'] ?? '😊',
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['name'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                if (data['note'] != null &&
                                    data['note'].toString().isNotEmpty)
                                  Text(data['note'],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}