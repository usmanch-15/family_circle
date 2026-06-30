import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final _picker = ImagePicker();

  // Camera se photo khinchna
  Future<File?> takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;
    return File(picked.path);
  }

  // Camera se video banana
  Future<File?> recordVideo() async {
    final picked = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // Gallery se photo choose karna
  Future<File?> pickPhotoFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return File(picked.path);
  }

  // Gallery se video choose karna
  Future<File?> pickVideoFromGallery() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return null;
    return File(picked.path);
  }

  // Multiple photos ek sath select karna
  Future<List<File>> pickMultiplePhotos() async {
    final picked = await _picker.pickMultiImage();
    return picked.map((x) => File(x.path)).toList();
  }
}