import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  // ─── Current user stream ──────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ─── Email / Password Signup ──────────────────────────
  Future<UserModel?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.updateDisplayName(name);

      final user = UserModel(
        uid:       cred.user!.uid,
        name:      name,
        email:     email,
        photoUrl:  null,
        role:      UserRole.member,
        createdAt: DateTime.now(),
      );

      // Firestore mein save karo
      await _firestore
          .collection(Collections.users)
          .doc(user.uid)
          .set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  // ─── Email / Password Login ───────────────────────────
  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserFromFirestore(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  // ─── Google Sign In ───────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user ne cancel kiya

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      final uid  = cred.user!.uid;

      // Pehli baar login ho to Firestore mein save karo
      final doc = await _firestore
          .collection(Collections.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        final user = UserModel(
          uid:       uid,
          name:      cred.user!.displayName ?? 'User',
          email:     cred.user!.email ?? '',
          photoUrl:  cred.user!.photoURL,
          role:      UserRole.member,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(Collections.users)
            .doc(uid)
            .set(user.toMap());
        return user;
      }

      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw 'Google login mein masla hua. Dobara koshish karein.';
    }
  }

  // ─── Logout ───────────────────────────────────────────
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Password Reset ───────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  // ─── Firestore se user lana ───────────────────────────
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore
        .collection(Collections.users)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // ─── Firebase error ko Urdu mein translate karna ──────
  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Yeh email pehle se registered hai.';
      case 'invalid-email':
        return 'Email sahi nahi hai.';
      case 'weak-password':
        return 'Password kam az kam 6 characters ka hona chahiye.';
      case 'user-not-found':
        return 'Yeh email registered nahi hai.';
      case 'wrong-password':
        return 'Password galat hai.';
      case 'too-many-requests':
        return 'Bohat zyada koshishein. Kuch der baad try karein.';
      default:
        return 'Kuch masla hua. Dobara koshish karein.';
    }
  }
}