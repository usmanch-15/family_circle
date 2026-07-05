import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../models/media_model.dart';

class MediaTile extends StatelessWidget {
  final MediaModel media;
  final VoidCallback onTap;

  const MediaTile({super.key, required this.media, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.cardBg,
        ),
        clipBehavior: Clip.antiAlias,
        child: media.type == MediaType.photo
            ? CachedNetworkImage(
          imageUrl: media.url,
          fit: BoxFit.cover,
          placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (_, __, ___) =>
          const Icon(Icons.broken_image, color: AppColors.textMuted),
        )
            : Center(
          child: Icon(
            media.type == MediaType.video
                ? Icons.play_circle_fill_rounded
                : media.type == MediaType.audio
                ? Icons.audiotrack_rounded
                : Icons.insert_drive_file_rounded,
            size: 36, color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}