import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/media_service.dart';
import '../models/media_model.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService();
});

final mediaStreamProvider = StreamProvider.family<List<MediaModel>, String>(
      (ref, familyId) {
    return ref.read(mediaServiceProvider).mediaStream(familyId);
  },
);

final mediaUploadingProvider = StateProvider<bool>((ref) => false);
final mediaUploadProgressProvider = StateProvider<double>((ref) => 0.0);