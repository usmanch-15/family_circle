import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import 'groups_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state   = null;

    try {
      // Firebase Auth se login
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // Firestore se user data fetch karo
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      UserModel user;

      if (doc.exists) {
        // User document hai
        user = UserModel.fromMap(doc.data()!);
      } else {
        // User document nahi hai - naya banao
        user = UserModel(
          uid:       uid,
          name:      cred.user!.displayName ?? _emailCtrl.text.split('@')[0],
          email:     cred.user!.email ?? '',
          photoUrl:  cred.user!.photoURL,
          familyIds: [],
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(user.toMap());
      }

      // State update karo
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
        case 'user-not-found':
          msg = 'Yeh email registered nahi hai.';
          break;
        case 'wrong-password':
          msg = 'Password galat hai.';
          break;
        case 'invalid-credential':
          msg = 'Email ya password galat hai.';
          break;
        case 'too-many-requests':
          msg = 'Bohat zyada koshishein. Kuch der baad try karein.';
          break;
        default:
          msg = 'Login mein masla hua: ${e.message}';
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
            end:   Alignment.bottomCenter,
            colors: [Color(0xFF6C3AE8), Color(0xFF8B5CF6)],
            stops:  [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Purple header ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.home_rounded, size: 38, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('Welcome Back',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Login to your Family Circle',
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
              // ── White card ─────────────────────────────
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:  Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Error
                          if (error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(error,
                                        style: const TextStyle(color: AppColors.error, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email
                          const Text('Email',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'aapki@email.com',
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email daalna zaroori hai';
                              if (!v.contains('@')) return 'Sahi email daalen';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const Text('Password',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password daalna zaroori hai';
                              if (v.length < 6) return 'Password 6 characters ka hona chahiye';
                              return null;
                            },
                          ),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Password bhool gaye?',
                                  style: TextStyle(color: AppColors.primary, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Login button
                          ElevatedButton(
                            onPressed: isLoading ? null : _loginWithEmail,
                            child: isLoading
                                ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Login',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 28),

                          // Signup link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Account nahi hai? ',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                ),
                                child: const Text('Sign Up',
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
}