import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> takePhoto() async {
    if (kIsWeb) {
      debugPrint('Camera web pe support nahi - mobile pe chalao');
      return null;
    }
    try {
      final xfile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (xfile == null) return null;
      return File(xfile.path);
    } catch (e) {
      debugPrint('takePhoto error: $e');
      return null;
    }
  }

  Future<File?> recordVideo() async {
    if (kIsWeb) {
      debugPrint('Video web pe support nahi - mobile pe chalao');
      return null;
    }
    try {
      final xfile = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );
      if (xfile == null) return null;
      return File(xfile.path);
    } catch (e) {
      debugPrint('recordVideo error: $e');
      return null;
    }
  }

  Future<File?> pickPhotoFromGallery() async {
    if (kIsWeb) {
      debugPrint('Gallery web pe support nahi - mobile pe chalao');
      return null;
    }
    try {
      final xfile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (xfile == null) return null;
      return File(xfile.path);
    } catch (e) {
      debugPrint('pickPhotoFromGallery error: $e');
      return null;
    }
  }

  Future<File?> pickVideoFromGallery() async {
    if (kIsWeb) {
      debugPrint('Gallery web pe support nahi - mobile pe chalao');
      return null;
    }
    try {
      final xfile = await _picker.pickVideo(source: ImageSource.gallery);
      if (xfile == null) return null;
      return File(xfile.path);
    } catch (e) {
      debugPrint('pickVideoFromGallery error: $e');
      return null;
    }
  }

  Future<List<File>> pickMultiplePhotos() async {
    if (kIsWeb) {
      debugPrint('Multi pick web pe support nahi - mobile pe chalao');
      return [];
    }
    try {
      final xfiles = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
      );
      return xfiles.map((x) => File(x.path)).toList();
    } catch (e) {
      debugPrint('pickMultiplePhotos error: $e');
      return [];
    }
  }
}