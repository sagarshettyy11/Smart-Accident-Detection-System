import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication service wrapping Firebase Auth.
class FirebaseAuthService {
  FirebaseAuthService._();

  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// The currently logged-in user, or null.
  static User? get currentUser => _auth.currentUser;

  /// Whether a user is currently authenticated.
  static bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes.
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Sign up with email + password.
  /// [fullName] is stored in Firestore under `users/{uid}`.
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    developer.log(
      'signUp called – email: $email',
      name: 'FirebaseAuthService',
    );

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          developer.log(
            'signUp TIMEOUT after 30 s',
            name: 'FirebaseAuthService',
          );
          throw TimeoutException('Sign-up request timed out. Please try again.');
        },
      );

      // Update display name
      if (fullName != null && credential.user != null) {
        await credential.user!.updateDisplayName(fullName);
      }

      // Store user profile in Firestore (non-blocking: don't let Firestore
      // errors prevent navigation — profile can be saved during setup).
      if (credential.user != null) {
        try {
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'email': email,
            'fullName': fullName ?? '',
            'full_name': fullName ?? '',
            'phone': phone ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (firestoreError) {
          developer.log(
            'Firestore profile write failed (non-fatal): $firestoreError',
            name: 'FirebaseAuthService',
          );
        }
      }

      developer.log(
        'signUp response – '
        'user id: ${credential.user?.uid}, '
        'email: ${credential.user?.email}',
        name: 'FirebaseAuthService',
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      developer.log(
        'signUp FirebaseAuthException – ${e.code}: ${e.message}',
        name: 'FirebaseAuthService',
        error: e,
      );
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e, st) {
      developer.log(
        'signUp unexpected error – $e',
        name: 'FirebaseAuthService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Sign in with email + password.
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    developer.log(
      'signIn called – email: $email',
      name: 'FirebaseAuthService',
    );

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          developer.log(
            'signIn TIMEOUT after 30 s',
            name: 'FirebaseAuthService',
          );
          throw TimeoutException('Sign-in request timed out. Please try again.');
        },
      );

      developer.log(
        'signIn response – '
        'user id: ${credential.user?.uid}',
        name: 'FirebaseAuthService',
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      developer.log(
        'signIn FirebaseAuthException – ${e.code}: ${e.message}',
        name: 'FirebaseAuthService',
        error: e,
      );
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e, st) {
      developer.log(
        'signIn unexpected error – $e',
        name: 'FirebaseAuthService',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Sign out the current user.
  static Future<void> signOut() async {
    developer.log('signOut called', name: 'FirebaseAuthService');
    await _auth.signOut();
    developer.log('signOut completed', name: 'FirebaseAuthService');
  }
}
