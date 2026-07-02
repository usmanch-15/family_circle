import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../services/deep_link_service.dart';
import '../widgets/ai_toggle_card.dart';
import 'groups_list_screen.dart';

class NewFamilySetupScreen extends ConsumerStatefulWidget {
  const NewFamilySetupScreen({super.key});

  @override
  ConsumerState<NewFamilySetupScreen> createState() => _NewFamilySetupScreenState();
}

class _NewFamilySetupScreenState extends ConsumerState<NewFamilySetupScreen> {
  final _nameCtrl = TextEditingController();
  int    _step       = 0;
  bool   _aiEnabled  = false;
  bool   _loading    = false;
  String? _error;
  String? _generatedLink;
  String? _inviteCode;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    setState(() { _loading = true; _error = null; });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final family = await ref.read(familyServiceProvider).createFamily(
        name:     _nameCtrl.text.trim(),
        adminUid: user.uid,
      );

      // AI enabled update karo Firestore mein
      if (_aiEnabled) {
        await FirebaseFirestore.instance
            .collection(Collections.families)
            .doc(family.id)
            .update({'aiEnabled': true});
      }

      final link = DeepLinkService().generateInviteLink(
        familyId:   family.id,
        familyName: family.name,
        inviteCode: family.inviteCode,
      );

      ref.read(currentUserProvider.notifier).state = user.copyWith(
        familyIds: [...user.familyIds, family.id],
      );

      setState(() {
        _generatedLink = link;
        _inviteCode    = family.inviteCode;
        _step          = 2;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          _step == 0 ? 'New Family' : _step == 1 ? 'AI Mediator' : 'Group Ready!',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    // ─── Step 0: Naam ─────────────────────────────────────
    if (_step == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.groups_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('Family ka naam kya hai?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Yeh sab members ko dikhega',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],

          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'maslan: Khan Family',
              prefixIcon: Icon(Icons.home_outlined, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) {
                setState(() => _error = 'Naam daalna zaroori hai');
                return;
              }
              setState(() { _error = null; _step = 1; });
            },
            child: const Text('Aagay badhein', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }

    // ─── Step 1: AI Toggle ─────────────────────────────────
    if (_step == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: const Color(0xFFF5F0FF), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.psychology_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('AI Mediator add karein?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Family masail mein AI neutral faisla dega',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),

          AiToggleCard(
            value:     _aiEnabled,
            onChanged: (v) => setState(() => _aiEnabled = v),
          ),

          const SizedBox(height: 16),

          // Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Baad mein Admin panel se on/off kar sakte hain',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _createGroup,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Group Banayein', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }

    // ─── Step 2: Link ready ────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success icon
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.check_circle_rounded, size: 36, color: Color(0xFF16A34A)),
        ),
        const SizedBox(height: 20),
        const Text('Group ban gaya! 🎉',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(
          _aiEnabled ? 'AI Mediator bhi active hai ✓' : 'Family members ko invite karein',
          style: TextStyle(color: _aiEnabled ? const Color(0xFF16A34A) : AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Invite link box
        if (_generatedLink != null) ...[
          const Text('Invite Link',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              border: Border.all(color: const Color(0xFF86EFAC)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invite code
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Text(
                    _inviteCode ?? '',
                    style: const TextStyle(fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedLink!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copy ho gaya!'), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Share.share('Family Circle pe join karein!\nCode: $_inviteCode\nLink: $_generatedLink');
                        },
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 42),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Join link info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Family member yeh code app mein "Join Family" mein type karein',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const GroupsListScreen()),
                (route) => false,
          ),
          child: const Text('Group mein jao', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}