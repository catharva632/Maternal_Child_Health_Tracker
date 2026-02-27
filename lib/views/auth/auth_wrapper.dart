import 'package:flutter/material.dart';
import '../../views/features/mood_tracker_screen.dart';
import '../../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboard/patient_dashboard.dart';
import '../dashboard/doctor_dashboard.dart';
import 'welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Bypass authentication for testing if flag is set
    if (kBypassAuth) {
      return const MoodTrackerScreen();
    }
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, then they are logged in
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const WelcomeScreen();
          }
          
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.done) {
                if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                  String role = roleSnapshot.data!.get('role') ?? 'patient';
                  if (role == 'doctor') {
                    return const DoctorDashboard();
                  } else {
                    return const PatientDashboard();
                  }
                }
                // Fallback if user doc doesn't exist yet but user is authenticated
                return const PatientDashboard();
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }
        
        // Checking auth state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
