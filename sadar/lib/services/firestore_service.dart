import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized Firestore service for all database operations.
///
/// Handles user profiles, vehicles, and emergency contacts.
/// All operations use the currently authenticated user's UID.
class FirestoreService {
  FirestoreService._();

  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // ── User Profile ──────────────────────────────────

  /// Save or update user profile data.
  static Future<void> saveUserProfile(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).set({
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get user profile data.
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = _uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    // Map 'fullName' to 'full_name' for UI compatibility
    if (data != null &&
        data.containsKey('fullName') &&
        !data.containsKey('full_name')) {
      data['full_name'] = data['fullName'];
    }
    return data;
  }

  // ── Emergency Contacts ────────────────────────────

  /// Get the contacts sub-collection reference for the current user.
  static CollectionReference<Map<String, dynamic>>? get _contactsRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('contacts');
  }

  /// Get all emergency contacts, ordered by creation time.
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final ref = _contactsRef;
    if (ref == null) return [];

    try {
      final snapshot = await ref.orderBy('createdAt').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // If 'createdAt' index doesn't exist, fall back to unordered
      final snapshot = await ref.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }
  }

  /// Add a new emergency contact.
  static Future<void> addEmergencyContact(Map<String, dynamic> data) async {
    final ref = _contactsRef;
    if (ref == null) return;

    await ref.add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  /// Delete an emergency contact by document ID.
  static Future<void> deleteEmergencyContact(String contactId) async {
    final ref = _contactsRef;
    if (ref == null) return;

    await ref.doc(contactId).delete();
  }

  // ── Vehicles ──────────────────────────────────────

  /// Save or update vehicle data.
  static Future<void> saveVehicle(Map<String, dynamic> data) async {
    final uid = _uid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc('default')
        .set({
          ...data,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Get vehicle data.
  static Future<Map<String, dynamic>?> getVehicle() async {
    final uid = _uid;
    if (uid == null) return null;

    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc('default')
        .get();
    if (!doc.exists) return null;
    return doc.data();
  }

  // ── Accident Alerts ─────────────────────────────

  /// Get accident alerts for the current user
  static Stream<List<Map<String, dynamic>>> listenAccidentAlerts() {
    final uid = _uid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection('accident_alerts')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final alerts = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Sort locally instead of Firestore
          alerts.sort((a, b) {
            final t1 = a['timestamp'] as Timestamp?;
            final t2 = b['timestamp'] as Timestamp?;
            return (t2?.compareTo(t1 ?? Timestamp(0, 0)) ?? 0);
          });

          return alerts;
        });
  }
}
