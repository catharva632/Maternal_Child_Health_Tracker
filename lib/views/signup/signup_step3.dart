import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../models/doctor_model.dart';
import '../../widgets/doctor_card.dart';

class SignupStep3 extends StatelessWidget {
  const SignupStep3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Doctor')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildTimeline(3),
              const SizedBox(height: 30),
              const Text(
                'Select your registered doctor from the list below to complete registration.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<DoctorModel>>(
                stream: PatientController().getDoctorsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final doctors = snapshot.data ?? [];
                  if (doctors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_search, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No doctors registered yet.\nPlease come back later or skip.', textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorCard(
                        doctor: doctor,
                        onTap: () {
                           _showConfirmDialog(context, doctor);
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => PatientController().registerPatient(context),
                child: Text(
                  'Skip / Register without Doctor',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, DoctorModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Doctor'),
        content: Text('Do you want to register with Dr. ${doctor.name} at ${doctor.clinicName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PatientController().saveDoctorDetails(doctor);
              PatientController().registerPatient(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF48FB1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFF48FB1),
          child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        Expanded(child: Container(height: 2, color: const Color(0xFFF48FB1))),
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFF48FB1),
          child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        Expanded(child: Container(height: 2, color: const Color(0xFFF48FB1))),
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFF48FB1),
          child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }
}
