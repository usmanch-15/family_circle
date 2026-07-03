import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';

import '../providers/groups_provider.dart';
import '../providers/auth_provider.dart';
import 'groups_list_screen.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _codeCtrl = TextEditingController();
  bool   _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (_codeCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Invite code daalna zaroori hai');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final family = await ref.read(familyServiceProvider).joinFamily(
        inviteCode: _codeCtrl.text.trim(),
        userUid:    user.uid,
      );

      if (family != null) {
        ref.read(currentUserProvider.notifier).state = user.copyWith(
          familyIds: [...user.familyIds, family.id],
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const GroupsListScreen()),
                (route) => false,
          );
        }
      }
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
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Family Join Karein', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.group_add_rounded, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Invite code daalen',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Jo link ya code family member ne share kiya hai woh yahan type karein',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 28),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _codeCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.none,
              style: const TextStyle(fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.w600, letterSpacing: 1),
              decoration: InputDecoration(
                hintText: 'maslan: KhanFamily-x9k2',
                hintStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.normal, letterSpacing: 0),
                prefixIcon: const Icon(Icons.tag, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
              onSubmitted: (_) => _join(),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _join,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Join Karein', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Invite code family admin se mangwayein. App nahi hai to Play Store link share karein.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}