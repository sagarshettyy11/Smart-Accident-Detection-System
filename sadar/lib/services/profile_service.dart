import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing user profiles and vehicles in Firestore.
class ProfileService {
  ProfileService._();

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  // ── Profiles ──────────────────────────────────────

  /// Fetch the current user's profile.
  static Future<Map<String, dynamic>?> getProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data();
    // Map Firestore 'fullName' field to 'full_name' for UI compatibility
    if (data != null && data.containsKey('fullName') && !data.containsKey('full_name')) {
      data['full_name'] = data['fullName'];
    }
    return data;
  }

  /// Create or update the current user's profile.
  static Future<void> upsertProfile(Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).set({
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Vehicles ──────────────────────────────────────

  /// Fetch the current user's vehicle.
  static Future<Map<String, dynamic>?> getVehicle() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc('default')
        .get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Create or update the current user's vehicle.
  static Future<void> upsertVehicle(Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc('default')
        .set({
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
