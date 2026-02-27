import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GamificationController {
  static final GamificationController _instance = GamificationController._internal();
  factory GamificationController() => _instance;
  GamificationController._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> unlockBadge(String badgeId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();
    
    if (doc.exists) {
      List<String> currentBadges = List<String>.from(doc.data()?['badges'] ?? []);
      if (!currentBadges.contains(badgeId)) {
        currentBadges.add(badgeId);
        await docRef.update({'badges': currentBadges});
      }
    }
  }
}
