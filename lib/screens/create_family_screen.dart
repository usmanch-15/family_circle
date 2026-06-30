import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../providers/family_provider.dart';

import 'home_screen.dart';

class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  ConsumerState<CreateFamilyScreen> createState() =>
      _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Family ka naam daalna zaroori hai');
      return;
    }

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

      ref.read(currentUserProvider.notifier).state =
          user.copyWith(familyId: family.id);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
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
        title: const Text('Family Banayein',
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
              child: const Icon(Icons.groups_rounded,
                  size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Apni Family ka naam likhein',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text(
              'Yeh naam sab family members ko dikhega',
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
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: 'maslan: Khan Family',
                prefixIcon: Icon(Icons.home_outlined,
                    color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _create,
              child: _loading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Text('Family Banayein',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}