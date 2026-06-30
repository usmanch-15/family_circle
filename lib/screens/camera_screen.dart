import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../services/camera_service.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final _cameraService = CameraService();
  bool _loading = false;

  Future<void> _handlePhoto() async {
    setState(() => _loading = true);
    final file = await _cameraService.takePhoto();
    setState(() => _loading = false);
    if (file != null && mounted) {
      Navigator.pop(context, file);
    }
  }

  Future<void> _handleVideo() async {
    setState(() => _loading = true);
    final file = await _cameraService.recordVideo();
    setState(() => _loading = false);
    if (file != null && mounted) {
      Navigator.pop(context, file);
    }
  }

  Future<void> _handleGalleryPhoto() async {
    setState(() => _loading = true);
    final file = await _cameraService.pickPhotoFromGallery();
    setState(() => _loading = false);
    if (file != null && mounted) {
      Navigator.pop(context, file);
    }
  }

  Future<void> _handleGalleryVideo() async {
    setState(() => _loading = true);
    final file = await _cameraService.pickVideoFromGallery();
    setState(() => _loading = false);
    if (file != null && mounted) {
      Navigator.pop(context, file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Camera',
            style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: [
            _OptionCard(
              icon: Icons.camera_alt_rounded,
              label: 'Photo khinchein',
              onTap: _handlePhoto,
            ),
            _OptionCard(
              icon: Icons.videocam_rounded,
              label: 'Video banayein',
              onTap: _handleVideo,
            ),
            _OptionCard(
              icon: Icons.photo_library_rounded,
              label: 'Gallery se photo',
              onTap: _handleGalleryPhoto,
            ),
            _OptionCard(
              icon: Icons.video_library_rounded,
              label: 'Gallery se video',
              onTap: _handleGalleryVideo,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}