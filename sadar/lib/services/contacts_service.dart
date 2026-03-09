import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing emergency contacts in Firestore.
class ContactsService {
  ContactsService._();

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Reference to the current user's emergency_contacts sub-collection.
  static CollectionReference<Map<String, dynamic>>? get _contactsRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('emergency_contacts');
  }

  /// Fetch all emergency contacts for the current user.
  static Future<List<Map<String, dynamic>>> getContacts() async {
    final ref = _contactsRef;
    if (ref == null) return [];

    final snapshot = await ref.orderBy('created_at').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Add a new emergency contact.
  static Future<void> addContact(Map<String, dynamic> data) async {
    final ref = _contactsRef;
    if (ref == null) return;

    await ref.add({
      ...data,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing emergency contact.
  static Future<void> updateContact(
      String contactId, Map<String, dynamic> data) async {
    final ref = _contactsRef;
    if (ref == null) return;

    await ref.doc(contactId).update({
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Delete an emergency contact.
  static Future<void> deleteContact(String contactId) async {
    final ref = _contactsRef;
    if (ref == null) return;

    await ref.doc(contactId).delete();
  }
}
