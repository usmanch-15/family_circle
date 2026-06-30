import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase auth state - login hai ya nahi
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user ka data (UserModel)
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

// Loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Error message
final authErrorProvider = StateProvider<String?>((ref) => null);