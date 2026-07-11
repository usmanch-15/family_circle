import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase Storage ki jagah Cloudinary use karte hain — free tier
/// (25GB storage + 25GB bandwidth/month) bina billing card ke milta hai.
///
/// Setup: cloudinary.com pe free account banayein, phir:
/// Settings > Upload > Add upload preset > Signing Mode: "Unsigned"
/// .env mein CLOUDINARY_CLOUD_NAME aur CLOUDINARY_UPLOAD_PRESET daalein.
class CloudinaryService {
  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get _uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  /// [resourceType]:
  ///  - 'image' → photos
  ///  - 'video' → videos AND audio/voice notes (Cloudinary inhe isi type mein rakhta hai)
  ///  - 'raw'   → documents (pdf, docx, waghera)
  ///  - 'auto'  → Cloudinary khud detect kar le
  Future<String> uploadFile({
    required File file,
    required String folder,
    String resourceType = 'auto',
  }) async {
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw 'Cloudinary configure nahi hai. .env file mein CLOUDINARY_CLOUD_NAME aur CLOUDINARY_UPLOAD_PRESET daalein.';
    }

    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw 'Upload fail ho gaya (${response.statusCode}). Cloudinary settings check karein.';
    }

    final data = jsonDecode(response.body);
    return data['secure_url'] as String;
  }

  /// Cloudinary se file delete karna — client-side unsigned delete
  /// possible nahi hoti (security ke liye signature chahiye hoti hai),
  /// isliye yahan sirf koshish karte hain aur fail silently ho jate hain.
  /// Files khud 'folder' structure mein Cloudinary dashboard se manually
  /// bhi delete ho sakti hain agar zaroorat pade.
  Future<void> deleteFile(String url) async {
    // Unsigned delete Cloudinary API se directly possible nahi;
    // isay skip kar rahe hain — sirf Firestore record delete hoga.
  }
}