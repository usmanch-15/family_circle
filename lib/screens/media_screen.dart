import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/groups_provider.dart';
import '../providers/media_provider.dart';
import '../models/media_model.dart';
import '../widgets/loading_widget.dart';
import 'media_viewer_screen.dart';

class MediaScreen extends ConsumerStatefulWidget {
  const MediaScreen({super.key});

  @override
  ConsumerState<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends ConsumerState<MediaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyId = ref.watch(currentGroupIdProvider);
    if (familyId == null) return const Scaffold(body: Center(child: Text('Family nahi mili')));

    final mediaAsync = ref.watch(mediaStreamProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Media', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload: Android app mein available'), behavior: SnackBarBehavior.floating),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Photos'),
            Tab(text: 'Videos'),
            Tab(text: 'Audio'),
          ],
        ),
      ),
      body: mediaAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (mediaList) {
          final photos = mediaList.where((m) => m.type == MediaType.photo).toList();
          final videos = mediaList.where((m) => m.type == MediaType.video).toList();
          final audios = mediaList.where((m) => m.type == MediaType.audio).toList();

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _MediaGrid(items: photos, emptyMsg: 'Koi photo nahi hai'),
              _MediaGrid(items: videos, emptyMsg: 'Koi video nahi hai'),
              _MediaGrid(items: audios, emptyMsg: 'Koi audio nahi hai', isAudio: true),
            ],
          );
        },
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  final List<MediaModel> items;
  final String emptyMsg;
  final bool isAudio;
  const _MediaGrid({required this.items, required this.emptyMsg, this.isAudio = false});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isAudio ? Icons.audiotrack_outlined : Icons.photo_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(emptyMsg, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    if (isAudio) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final m = items[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.audiotrack_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.uploaderName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(m.caption ?? 'Audio file', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 32),
              ],
            ),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerScreen(media: m))),
          child: Stack(
            fit: StackFit.expand,
            children: [
              m.url.isNotEmpty
                  ? Image.network(m.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.cardBg, child: const Icon(Icons.broken_image, color: AppColors.textMuted)))
                  : Container(color: AppColors.cardBg),
              if (m.type == MediaType.video)
                const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 32)),
            ],
          ),
        );
      },
    );
  }
}