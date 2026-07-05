import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/media_model.dart';

class MediaViewerScreen extends StatelessWidget {
  final MediaModel media;
  const MediaViewerScreen({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(media.uploaderName,
                style: const TextStyle(color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w600)),
            Text(Helpers.timeAgo(media.uploadedAt),
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: media.type == MediaType.photo
            ? InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: media.url,
            placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: Colors.white)),
            errorWidget: (_, __, ___) => const Icon(
                Icons.broken_image, color: Colors.white, size: 48),
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              media.type == MediaType.video
                  ? Icons.play_circle_fill_rounded
                  : Icons.audiotrack_rounded,
              size: 80, color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              media.type == MediaType.video
                  ? 'Video player Android mein available hoga'
                  : 'Audio player Android mein available hoga',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (media.caption != null)
                    Text(media.caption!,
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                  Text(
                    '${Helpers.timeAgo(media.uploadedAt)} · ${Helpers.formatFileSize(media.sizeInBytes)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}