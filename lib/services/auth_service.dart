import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Friendly, user-facing authentication error.
class AuthFailure implements Exception {
  final String message;
  final String code;
  const AuthFailure(this.message, [this.code = '']);
  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db, GoogleSignIn? google})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _google = google ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _google;

  Stream<User?> get userChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  static bool usesPassword(User u) =>
      u.providerData.any((p) => p.providerId == 'password');
  static bool usesGoogle(User u) =>
      u.providerData.any((p) => p.providerId == 'google.com');

  // ---------------------------------------------------------------- sign up
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
        final user = cred.user!;
        await user.updateDisplayName(name.trim());
        await _saveProfile(user, name: name.trim(), isNew: true);
      });

  // ---------------------------------------------------------------- sign in
  Future<void> signIn({required String email, required String password}) =>
      _guard(() async {
        final cred = await _auth.signInWithEmailAndPassword(
            email: email.trim(), password: password);
        await _saveProfile(cred.user!, isNew: false);
      });

  Future<void> signInWithGoogle() => _guard(() async {
        UserCredential cred;
        if (kIsWeb) {
          cred = await _auth.signInWithPopup(GoogleAuthProvider());
        } else {
          final account = await _google.signIn();
          if (account == null) {
            throw const AuthFailure('Google sign-in was cancelled.', 'cancelled');
          }
          final auth = await account.authentication;
          cred = await _auth.signInWithCredential(GoogleAuthProvider.credential(
            accessToken: auth.accessToken,
            idToken: auth.idToken,
          ));
        }
        await _saveProfile(cred.user!,
            isNew: cred.additionalUserInfo?.isNewUser ?? false);
      });

  // --------------------------------------------------------------- recovery
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  // ---------------------------------------------------------------- account
  Future<void> updateName(String name) => _guard(() async {
        final u = _requireUser();
        await u.updateDisplayName(name.trim());
        await _db.collection('users').doc(u.uid).set(
            {'name': name.trim(), 'updatedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true));
        await u.reload();
      });

  Future<void> changePassword(
          {required String current, required String next}) =>
      _guard(() async {
        final u = _requireUser();
        await _reauthenticate(u, password: current);
        await u.updatePassword(next);
      });

  /// Deletes tasks, profile and the Firebase account. Re-authenticates first
  /// so a failed re-auth never leaves the user with half-deleted data.
  Future<void> deleteAccount({String? password}) => _guard(() async {
        final u = _requireUser();
        await _reauthenticate(u, password: password);
        final userDoc = _db.collection('users').doc(u.uid);
        final tasks = await userDoc.collection('tasks').get();
        for (var i = 0; i < tasks.docs.length; i += 400) {
          final batch = _db.batch();
          for (final d in tasks.docs.skip(i).take(400)) {
            batch.delete(d.reference);
          }
          await batch.commit();
        }
        await userDoc.delete();
        await u.delete();
        if (!kIsWeb) {
          try {
            await _google.signOut();
          } catch (_) {}
        }
      });

  Future<void> signOut() async {
    try {
      if (!kIsWeb) await _google.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // ---------------------------------------------------------------- helpers
  User _requireUser() {
    final u = _auth.currentUser;
    if (u == null) {
      throw const AuthFailure('You are signed out. Please sign in again.');
    }
    return u;
  }

  Future<void> _reauthenticate(User u, {String? password}) async {
    if (usesPassword(u)) {
      if (password == null || password.isEmpty) {
        throw const AuthFailure('Please enter your password to continue.');
      }
      await u.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: u.email!, password: password));
    } else if (usesGoogle(u)) {
      if (kIsWeb) {
        await u.reauthenticateWithPopup(GoogleAuthProvider());
      } else {
        final account = await _google.signIn();
        if (account == null) {
          throw const AuthFailure('Google sign-in was cancelled.', 'cancelled');
        }
        final a = await account.authentication;
        await u.reauthenticateWithCredential(GoogleAuthProvider.credential(
            accessToken: a.accessToken, idToken: a.idToken));
      }
    }
  }

  Future<void> _saveProfile(User user, {String? name, required bool isNew}) {
    final data = <String, dynamic>{
      'name': name ?? user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      'lastLoginAt': FieldValue.serverTimestamp(),
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
    };
    return _db
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_message(e), e.code);
    } on FirebaseException catch (e) {
      throw AuthFailure(
          e.code == 'permission-denied'
              ? 'You do not have permission to do that.'
              : 'Something went wrong (${e.code}). Please try again.',
          e.code);
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  static String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Try logging in.';
      case 'weak-password':
        return 'Choose a stronger password (at least 8 characters).';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase yet.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and retry.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }
}
