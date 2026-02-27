import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/auth/role_selection_screen.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '559376582323-39gp02dc8f49nkkgbjiu0sv3tsqqfi0q.apps.googleusercontent.com',
  );
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user profile already exists in Firestore
        final userDoc = await _db.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final role = userDoc.data()?['role'];
          if (role == 'doctor') {
            Navigator.pushNamedAndRemoveUntil(context, '/doctorDashboard', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
          }
        } else {
          // New user: Redirect to Role Selection Screen
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoleSelectionScreen(
                  email: user.email!,
                  uid: user.uid,
                  displayName: user.displayName,
                  photoUrl: user.photoURL,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
    }
  }

  Future<void> unifiedLogin(BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        final userDoc = await _db.collection('users').doc(credential.user!.uid).get();
        if (userDoc.exists) {
          final role = userDoc.data()?['role'];
          if (role == 'doctor') {
            Navigator.pushNamedAndRemoveUntil(context, '/doctorDashboard', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
          }
        } else {
           // Default if no role found
           Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
    }
  }

  Future<void> loginPatient(BuildContext context, String email, String password) async {
    await unifiedLogin(context, email, password);
  }

  Future<void> loginDoctor(BuildContext context, String email, String password) async {
    await unifiedLogin(context, email, password);
  }

  Future<void> registerDoctor({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String clinicName,
    required String specialization,
    required String phone,
    required String address,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'clinicName': clinicName,
          'specialization': specialization,
          'phone': phone,
          'address': address,
          'role': 'doctor',
          'createdAt': FieldValue.serverTimestamp(),
        });
        Navigator.pushNamedAndRemoveUntil(context, '/doctorDashboard', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: $e")),
      );
    }
  }

  void signupPatient(BuildContext context) {
    Navigator.pushNamed(context, '/signup1');
  }

  void signupDoctor(BuildContext context) {
    Navigator.pushNamed(context, '/doctorSignup');
  }

  Future<Map<String, dynamic>?> getDoctorProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> signOut(BuildContext context) async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
