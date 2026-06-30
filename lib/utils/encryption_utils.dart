import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionUtils {
  // Simple text ko encode karna (documents/passwords ke liye base64)
  static String encodeText(String plainText) {
    final bytes = utf8.encode(plainText);
    return base64.encode(bytes);
  }

  static String decodeText(String encodedText) {
    final bytes = base64.decode(encodedText);
    return utf8.decode(bytes);
  }

  // Password ya sensitive data ka hash banana (one-way, kabhi decode nahi hoga)
  static String hashText(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Compare karna ke hash match karta hai ya nahi
  static bool verifyHash(String plainText, String hash) {
    return hashText(plainText) == hash;
  }

  // Random secure token banana - documents access ke liye
  static String generateAccessToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return hashText(timestamp).substring(0, 16);
  }
}
