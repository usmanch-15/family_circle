class InviteLinkModel {
  final String familyId;
  final String familyName;
  final String inviteCode;

  InviteLinkModel({
    required this.familyId,
    required this.familyName,
    required this.inviteCode,
  });

  // Pura shareable link banata hai - jaise WhatsApp
  String get fullLink => 'https://familycircle.app/join/$inviteCode';

  // Link se parse karke wapis code nikalna
  static String? extractCode(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    if (segments.length < 2 || segments[0] != 'join') return null;
    return segments[1];
  }
}