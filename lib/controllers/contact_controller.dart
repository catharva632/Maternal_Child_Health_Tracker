import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact_model.dart';

class ContactController {
  static final ContactController _instance = ContactController._internal();
  factory ContactController() => _instance;
  ContactController._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<ContactModel> _contacts = [];

  Future<void> addContact(String name, String phone) async {
    final contact = ContactModel(name: name, phone: phone);
    
    // Always save locally
    _contacts.add(contact);

    final user = _auth.currentUser;
    if (user != null) {
      // Save to Firestore subcollection only if logged in
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .add(contact.toMap());
    }
  }

  Future<void> fetchContacts() async {
    final user = _auth.currentUser;
    if (user == null) return; // Keep existing local contacts for bypass mode

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .get();

    _contacts.clear();
    for (var doc in snapshot.docs) {
      _contacts.add(ContactModel.fromMap(doc.data()));
    }
  }

  List<ContactModel> getContacts() {
    return _contacts;
  }
}
