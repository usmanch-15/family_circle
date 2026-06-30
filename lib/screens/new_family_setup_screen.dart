import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/groups_provider.dart';
import '../services/deep_link_service.dart';
import '../widgets/ai_toggle_card.dart';
import '../widgets/invite_link_card.dart';
import 'groups_list_screen.dart';

class NewFamilySetupScreen extends ConsumerStatefulWidget {
  const NewFamilySetupScreen({super.key});

  @override
  ConsumerState<NewFamilySetupScreen> createState() =>
      _NewFamilySetupScreenState();
}

class _NewFamilySetupScreenState extends ConsumerState<NewFamilySetupScreen> {
  final _nameCtrl = TextEditingController();
  int _step = 0; // 0 = naam, 1 = AI toggle, 2 = link ready
  bool _aiEnabled = false;
  bool _loading = false;
  String? _error;
  String? _generatedLink;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final family = await ref.read(familyServiceProvider).createFamily(
        name: _nameCtrl.text.trim(),
        adminUid: user.uid,
      );

      // aiEnabled update karo
      // (FamilyService mein direct field update - simple approach)
      final link = DeepLinkService().generateInviteLink(
        familyId: family.id,
        familyName: family.name,
        inviteCode: family.inviteCode,
      );

      ref.read(currentUserProvider.notifier).state = user.copyWith(
        familyIds: [...user.familyIds, family.id],
      );

      setState(() {
        _generatedLink = link;
        _step = 2;
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
        title: const Text('New Family',
            style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    // Step 0: Naam
    if (_step == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Family ka naam',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Yeh sab members ko dikhega',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'maslan: Khan Family'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) {
                setState(() => _error = 'Naam daalna zaroori hai');
                return;
              }
              setState(() {
                _error = null;
                _step = 1;
              });
            },
            child: const Text('Aagay badhein'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
        ],
      );
    }

    // Step 1: AI toggle
    if (_step == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Mediator',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Family masail mein AI fair faisla dega',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          AiToggleCard(
            value: _aiEnabled,
            onChanged: (v) => setState(() => _aiEnabled = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _createGroup,
            child: _loading
                ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Text('Group Banayein'),
          ),
        ],
      );
    }

    // Step 2: Link ready
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.check_circle, size: 40, color: Color(0xFF16A34A)),
        ),
        const SizedBox(height: 20),
        const Text('Group ban gaya!',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Yeh link family members ko share karein',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        if (_generatedLink != null)
          InviteLinkCard(
            link: _generatedLink!,
            onShare: () {
              Share.share(
                'Mujhe Family Circle pe join karein: $_generatedLink',
              );
            },
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const GroupsListScreen()),
                (route) => false,
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
