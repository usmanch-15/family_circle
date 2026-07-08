import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../utils/constants.dart';

class SearchService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<ChatModel>> searchMessages({
    required String familyId,
    required String query,
    String? senderUid,
  }) async {
    var ref = _firestore
        .collection(Collections.families)
        .doc(familyId)
        .collection(Collections.chats)
        .where('type', isEqualTo: 'text')
        .orderBy('sentAt', descending: true)
        .limit(200);

    if (senderUid != null) {
      ref = ref.where('senderUid', isEqualTo: senderUid);
    }

    final snap  = await ref.get();
    final lower = query.toLowerCase();

    return snap.docs
        .map((d) => ChatModel.fromMap(d.data(), d.id))
        .where((m) => m.text?.toLowerCase().contains(lower) ?? false)
        .toList();
  }
}
