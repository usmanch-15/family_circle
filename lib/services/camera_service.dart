import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class CameraService {
  // Web pe yeh sab kaam nahi karta - mobile only
  // Jab Android pe move karein ge tab image_picker wapis add karein ge

  Future<File?> takePhoto() async {
    if (kIsWeb) {
      debugPrint('Camera web pe support nahi - mobile pe chalao');
      return null;
    }
    return null;
  }

  Future<File?> recordVideo() async {
    if (kIsWeb) {
      debugPrint('Video web pe support nahi - mobile pe chalao');
      return null;
    }
    return null;
  }

  Future<File?> pickPhotoFromGallery() async {
    if (kIsWeb) {
      debugPrint('Gallery web pe support nahi - mobile pe chalao');
      return null;
    }
    return null;
  }

  Future<File?> pickVideoFromGallery() async {
    if (kIsWeb) {
      debugPrint('Gallery web pe support nahi - mobile pe chalao');
      return null;
    }
    return null;
  }

  Future<List<File>> pickMultiplePhotos() async {
    if (kIsWeb) {
      debugPrint('Multi pick web pe support nahi - mobile pe chalao');
      return [];
    }
    return [];
  }
}