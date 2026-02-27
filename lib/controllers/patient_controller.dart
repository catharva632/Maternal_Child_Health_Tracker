import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';
import '../models/doctor_model.dart';

class PatientController {
  static final PatientController _instance = PatientController._internal();
  factory PatientController() => _instance;
  PatientController._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  PatientModel? currentPatient;
  String? tempPassword;

  void savePersonalDetails({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String pincode,
    required String state,
    String? password,
  }) {
    currentPatient = PatientModel(
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      pincode: pincode,
      state: state,
    );
    tempPassword = password;
  }

  void saveMedicalDetails({
    required int week,
    required double weight,
    required double height,
    required List<String> conditions,
  }) {
    if (currentPatient != null) {
      currentPatient!.pregnancyWeek = week;
      currentPatient!.weight = weight;
      currentPatient!.height = height;
      currentPatient!.medicalConditions = conditions;
    }
  }

  void saveDoctorDetails(DoctorModel doctor) {
    if (currentPatient != null) {
      currentPatient!.doctorName = doctor.name;
      currentPatient!.doctorPhone = doctor.phone;
      currentPatient!.hospitalName = doctor.clinicName;
      // We can also use hospitalPhone if DoctorModel had one, 
      // otherwise reuse clinic phone or a mock receptionist number for now.
      currentPatient!.hospitalPhone = doctor.phone; 
      currentPatient!.hospitalAddress = doctor.address;
    }
  }

  Future<void> registerPatient(BuildContext context) async {
    if (currentPatient == null || tempPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incomplete details. Please go back.")),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: currentPatient!.email,
        password: tempPassword!,
      );

      if (userCredential.user != null) {
        await _db.collection('users').doc(userCredential.user!.uid).set(
          currentPatient!.toMap()
        );
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: $e")),
      );
    }
  }

  Stream<PatientModel?> getPatientStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _db.collection('users').doc(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return PatientModel.fromMap(snapshot.data()!);
    });
  }

  Stream<List<PatientModel>> getPatientsForDoctor(String doctorName) {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .where('doctorName', isEqualTo: doctorName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> updateDnaProfile({
    required String diet,
    required bool isWorking,
    required bool isHighRisk,
    required bool isFirstBaby,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).update({
      'diet': diet,
      'isWorkingProfessional': isWorking,
      'isHighRisk': isHighRisk,
      'isFirstBaby': isFirstBaby,
    });
  }
}
