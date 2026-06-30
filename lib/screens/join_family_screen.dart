import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../providers/family_provider.dart';

import 'home_screen.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
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

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final family = await ref.read(familyServiceProvider).joinFamily(
        inviteCode: _codeCtrl.text.trim(),
        userUid: user.uid,
      );

      if (family != null) {
        ref.read(currentUserProvider.notifier).state =
            user.copyWith(familyId: family.id);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
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
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Family Join Karein',
            style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.group_add_rounded,
                  size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Invite code daalein',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text(
              'Jo link aapko family se mila hai, uska code yahan daalein',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 13)),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                hintText: 'maslan: KhanFamily-x9k2',
                prefixIcon: Icon(Icons.link, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _join,
              child: _loading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Text('Join Karein',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}