import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

import '../providers/media_provider.dart';
import '../models/media_model.dart';
import '../widgets/media_tile.dart';
import '../widgets/loading_widget.dart';
import 'media_viewer_screen.dart';

class MediaScreen extends ConsumerWidget {
  const MediaScreen({super.key});

  Future<void> _upload(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user?.familyId == null) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    ref.read(mediaUploadingProvider.notifier).state = true;
    try {
      await ref.read(mediaServiceProvider).uploadMedia(
        file: picked.path as dynamic,
        familyId: user!.familyId!,
        uploaderUid: user.uid,
        uploaderName: user.name,
        type: MediaType.photo,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload error: $e')));
      }
    } finally {
      ref.read(mediaUploadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final familyId = user?.familyId;
    final isUploading = ref.watch(mediaUploadingProvider);

    if (familyId == null) {
      return const Scaffold(body: Center(child: Text('Family nahi mili')));
    }

    final mediaAsync = ref.watch(mediaStreamProvider(familyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Memories',
            style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined,
                color: AppColors.primary),
            onPressed:
            isUploading ? null : () => _upload(context, ref),
          ),
        ],
      ),
      body: isUploading
          ? const LoadingWidget(message: 'Upload ho raha hai...')
          : mediaAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (mediaList) {
          if (mediaList.isEmpty) {
            return const Center(
              child: Text('Abhi koi media nahi hai',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: mediaList.length,
            itemBuilder: (context, i) {
              final media = mediaList[i];
              return MediaTile(
                media: media,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MediaViewerScreen(media: media),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}