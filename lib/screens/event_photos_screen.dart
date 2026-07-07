import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class EventPhotosScreen extends ConsumerStatefulWidget {
  final String familyId;
  final String eventTitle;
  const EventPhotosScreen(
      {super.key, required this.familyId, required this.eventTitle});

  @override
  ConsumerState<EventPhotosScreen> createState() =>
      _EventPhotosScreenState();
}

class _EventPhotosScreenState extends ConsumerState<EventPhotosScreen> {
  bool _uploading = false;

  Future<void> _addPhotoUrl() async {
    final ctrl = TextEditingController();
    final url  = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Photo URL add karein'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
              hintText: 'https://example.com/photo.jpg'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (url == null || url.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _uploading = true);
    try {
      await FirebaseFirestore.instance
          .collection(Collections.families)
          .doc(widget.familyId)
          .collection('event_photos')
          .add({
        'url':          url,
        'eventTitle':   widget.eventTitle,
        'uploaderUid':  user.uid,
        'uploaderName': user.name,
        'uploadedAt':   Timestamp.now(),
      });
    } finally {
      setState(() => _uploading = false);
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
        title: Text(widget.eventTitle,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined,
                color: Colors.white),
            onPressed: _uploading ? null : _addPhotoUrl,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Collections.families)
            .doc(widget.familyId)
            .collection('event_photos')
            .where('eventTitle', isEqualTo: widget.eventTitle)
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: AppColors.cardBg, shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library_outlined,
                        size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  const Text('Koi photo nahi hai',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addPhotoUrl,
                    icon: const Icon(Icons.add),
                    label: const Text('Photo Add Karein'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data =
              docs[i].data() as Map<String, dynamic>;
              final url = data['url'] ?? '';
              return GestureDetector(
                onTap: () => _viewPhoto(context, url,
                    data['uploaderName'] ?? ''),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.cardBg,
                        child: const Icon(Icons.broken_image,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewPhoto(
      BuildContext context, String url, String uploaderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(uploaderName,
                style: const TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(imageUrl: url),
            ),
          ),
        ),
      ),
    );
  }
}