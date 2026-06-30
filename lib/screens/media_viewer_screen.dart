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
        title: Text(media.uploaderName,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
      body: Center(
        child: media.type == MediaType.photo
            ? InteractiveViewer(
          child: CachedNetworkImage(imageUrl: media.url),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              media.type == MediaType.video
                  ? Icons.play_circle_fill_rounded
                  : Icons.audiotrack_rounded,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Video/Audio player yahan integrate hoga',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black,
        child: Text(
          '${Helpers.timeAgo(media.uploadedAt)} · ${Helpers.formatFileSize(media.sizeInBytes)}',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ),
    );
  }
}
