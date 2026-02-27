import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleSelectionScreen extends StatelessWidget {
  final String email;
  final String uid;
  final String? displayName;
  final String? photoUrl;

  const RoleSelectionScreen({
    super.key,
    required this.email,
    required this.uid,
    this.displayName,
    this.photoUrl,
  });

  Future<void> _registerWithRole(BuildContext context, String role) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (role == 'doctor') {
        Navigator.pushNamedAndRemoveUntil(context, '/doctorDashboard', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save role: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Registration')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select your role to continue',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Signing in as: $email',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40),
            _buildRoleCard(
              context,
              'I am a Patient',
              Icons.person_outline,
              () => _registerWithRole(context, 'patient'),
            ),
            const SizedBox(height: 24),
            _buildRoleCard(
              context,
              'I am a Doctor',
              Icons.medical_services_outlined,
              () => _registerWithRole(context, 'doctor'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.check_circle_outline),
            ],
          ),
        ),
      ),
    );
  }
}
