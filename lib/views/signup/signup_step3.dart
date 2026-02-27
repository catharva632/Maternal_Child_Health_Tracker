import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../models/doctor_model.dart';

class SignupStep3 extends StatelessWidget {
  const SignupStep3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTimeline(3),
            const SizedBox(height: 50),
            _buildChoiceCard(
              context,
              'Yes, I have a Doctor',
              Icons.check_circle_outline,
              () => _showDoctorDetailsDialog(context),
            ),
            const SizedBox(height: 20),
            _buildChoiceCard(
              context,
              "No, I don't have a Doctor",
              Icons.help_outline,
              () => Navigator.pushNamed(context, '/selectDoctor'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorDetailsDialog(BuildContext context) {
    final nameController = TextEditingController();
    final hospitalController = TextEditingController();
    final phoneController = TextEditingController();
    final clinicPhoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Doctor Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(nameController, 'Doctor Name'),
              _buildDialogField(hospitalController, 'Clinic/Hospital Name'),
              _buildDialogField(phoneController, 'Doctor Phone'),
              _buildDialogField(clinicPhoneController, 'Clinic Contact No'),
              _buildDialogField(addressController, 'Clinic Address'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final doctor = DoctorModel(
                name: nameController.text,
                clinicName: hospitalController.text,
                phone: phoneController.text, // Doctor Phone
                address: addressController.text,
                rating: 0.0,
                distance: 'Manual Entry',
              );
              PatientController().saveDoctorDetails(doctor);
              Navigator.pop(context);
              PatientController().registerPatient(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _buildChoiceCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: const Color(0xFFF48FB1)),
              const SizedBox(width: 20),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
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
        Container(width: 40, height: 2, color: const Color(0xFFF48FB1)),
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFF48FB1),
          child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        Container(width: 40, height: 2, color: const Color(0xFFF48FB1)),
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFF48FB1),
          child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }
}
