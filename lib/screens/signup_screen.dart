import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'groups_list_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure      = true;
  bool _obscureConf  = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state   = null;

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      await cred.user!.updateDisplayName(_nameCtrl.text.trim());

      final user = UserModel(
        uid:       cred.user!.uid,
        name:      _nameCtrl.text.trim(),
        email:     _emailCtrl.text.trim(),
        photoUrl:  null,
        familyIds: [],
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());

      ref.read(currentUserProvider.notifier).state = user;

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const GroupsListScreen()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Yeh email pehle se registered hai.';
          break;
        case 'invalid-email':
          msg = 'Email sahi nahi hai.';
          break;
        case 'weak-password':
          msg = 'Password kam az kam 6 characters ka hona chahiye.';
          break;
        default:
          msg = 'Signup mein masla hua: ${e.message}';
      }
      ref.read(authErrorProvider.notifier).state = msg;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = 'Kuch masla hua: $e';
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error     = ref.watch(authErrorProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C3AE8), Color(0xFF8B5CF6)],
            stops: [0.0, 0.30],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Account Banayein',
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Family Circle mein shamil ho jao',
                        style: TextStyle(fontSize: 14,
                            color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(error,
                                      style: const TextStyle(
                                          color: AppColors.error, fontSize: 13))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _label('Naam'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Ali Khan',
                              prefixIcon: Icon(Icons.person_outline,
                                  color: AppColors.textMuted),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Naam daalna zaroori hai' : null,
                          ),
                          const SizedBox(height: 14),
                          _label('Email'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'aapki@email.com',
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: AppColors.textMuted),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Email daalna zaroori hai';
                              if (!v.contains('@')) return 'Sahi email daalen';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _label('Password'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outlined,
                                  color: AppColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Password daalna zaroori hai';
                              if (v.length < 6)
                                return 'Kam az kam 6 characters chahiye';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _label('Password Confirm Karein'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscureConf,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outlined,
                                  color: AppColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConf
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                    color: AppColors.textMuted),
                                onPressed: () =>
                                    setState(() => _obscureConf = !_obscureConf),
                              ),
                            ),
                            validator: (v) {
                              if (v != _passCtrl.text)
                                return 'Password match nahi karta';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isLoading ? null : _signup,
                            child: isLoading
                                ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                                : const Text('Account Banayein',
                                style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Pehle se account hai? ',
                                  style: TextStyle(
                                      color: AppColors.textSecondary, fontSize: 14)),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text('Login karein',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary));
}