import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../providers/auth_provider.dart';

class FamilyNewsFeedScreen extends ConsumerStatefulWidget {
  final String familyId;
  const FamilyNewsFeedScreen(
      {super.key, required this.familyId});

  @override
  ConsumerState<FamilyNewsFeedScreen> createState() =>
      _FamilyNewsFeedScreenState();
}

class _FamilyNewsFeedScreenState
    extends ConsumerState<FamilyNewsFeedScreen> {
  final _postCtrl = TextEditingController();
  bool _posting   = false;

  @override
  void dispose() {
    _postCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_postCtrl.text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _posting = true);
    try {
      await FirebaseFirestore.instance
          .collection(Collections.families)
          .doc(widget.familyId)
          .collection('news_feed')
          .add({
        'uid':       user.uid,
        'name':      user.name,
        'photoUrl':  user.photoUrl,
        'text':      _postCtrl.text.trim(),
        'likes':     [],
        'createdAt': Timestamp.now(),
      });
      _postCtrl.clear();
    } finally {
      setState(() => _posting = false);
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
        title: const Text('Family Feed 📰',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Post box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.cardBg,
                  child: Text(
                    Helpers.getInitials(
                        ref.watch(currentUserProvider)?.name ?? 'U'),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _postCtrl,
                    decoration: InputDecoration(
                      hintText: 'Koi update share karein...',
                      hintStyle: const TextStyle(
                          color: AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _post(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _posting ? null : _post,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _posting
                          ? AppColors.textMuted
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _posting
                        ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Feed
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(Collections.families)
                  .doc(widget.familyId)
                  .collection('news_feed')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📰',
                            style: TextStyle(fontSize: 48)),
                        SizedBox(height: 14),
                        Text('Koi post nahi hai',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 15)),
                        SizedBox(height: 8),
                        Text('Family ke sath kuch share karein!',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final data =
                    docs[i].data() as Map<String, dynamic>;
                    final likes = List<String>.from(
                        data['likes'] ?? []);
                    final uid =
                        ref.read(currentUserProvider)?.uid ?? '';
                    final isLiked = likes.contains(uid);

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.cardBg,
                                backgroundImage:
                                data['photoUrl'] != null
                                    ? NetworkImage(data['photoUrl'])
                                    : null,
                                child: data['photoUrl'] == null
                                    ? Text(
                                    Helpers.getInitials(
                                        data['name'] ?? 'U'),
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w700))
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(data['name'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.w600)),
                                    Text(
                                      Helpers.timeAgo((data['createdAt']
                                      as Timestamp)
                                          .toDate()),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(data['text'] ?? '',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  height: 1.4)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final ref2 = FirebaseFirestore
                                      .instance
                                      .collection(
                                      Collections.families)
                                      .doc(widget.familyId)
                                      .collection('news_feed')
                                      .doc(docs[i].id);
                                  await ref2.update({
                                    'likes': isLiked
                                        ? FieldValue.arrayRemove(
                                        [uid])
                                        : FieldValue.arrayUnion(
                                        [uid]),
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isLiked
                                          ? Colors.red
                                          : AppColors.textMuted,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      likes.isEmpty
                                          ? 'Like'
                                          : '${likes.length}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: isLiked
                                              ? Colors.red
                                              : AppColors.textMuted,
                                          fontWeight:
                                          FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}