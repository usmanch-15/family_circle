import '../models/invite_link_model.dart';

class DeepLinkService {
  // App store ka link - agar user ke paas app nahi hai
  static const String playStoreLink =
      'https://play.google.com/store/apps/details?id=com.familycircle.app';
  static const String appStoreLink =
      'https://apps.apple.com/app/family-circle/id0000000000';

  // Invite link generate karna
  String generateInviteLink({
    required String familyId,
    required String familyName,
    required String inviteCode,
  }) {
    final model = InviteLinkModel(
      familyId: familyId,
      familyName: familyName,
      inviteCode: inviteCode,
    );
    return model.fullLink;
  }

  // App khulne par link se invite code nikalna
  String? parseInviteCode(String incomingLink) {
    return InviteLinkModel.extractCode(incomingLink);
  }

  // Super admin link parse karna - /admin/secret-key
  bool isSuperAdminLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return false;
    return uri.pathSegments.isNotEmpty &&
        uri.pathSegments[0] == 'admin';
  }
}