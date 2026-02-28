import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../models/doctor_model.dart';
import '../../widgets/doctor_card.dart';

class SelectDoctorScreen extends StatelessWidget {
  const SelectDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DoctorModel> doctors = [
      DoctorModel(
        name: 'Dr. Priya Sharma',
        clinicName: 'Grace Maternity Clinic',
        phone: '9876543210',
        address: '123 Health Ave, Pune',
        rating: 4.8,
        distance: '2.5 km',
      ),
      DoctorModel(
        name: 'Dr. Rahul Mehta',
        clinicName: 'LifeCare Hospital',
        phone: '9876543211',
        address: '456 Wellness Rd, Pune',
        rating: 4.5,
        distance: '4.2 km',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Doctor'),
        actions: [
          TextButton(
            onPressed: () => PatientController().registerPatient(context),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return DoctorCard(
            doctor: doctors[index],
            onTap: () {
              PatientController().saveDoctorDetails(doctors[index]);
              PatientController().registerPatient(context);
            },
          );
        },
      ),
    );
  }
}
