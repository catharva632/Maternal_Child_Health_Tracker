import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../models/patient_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

  Future<void> _makeCall(BuildContext context, String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PatientModel?>(
      stream: PatientController().getPatientStream(),
      builder: (context, snapshot) {
        final patient = snapshot.data;
        
        return Scaffold(
          appBar: AppBar(title: const Text('Hospital & Vaccination')),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDoctorCard(context, patient),
                      const SizedBox(height: 24),
                      Text(
                        'Next Appointment: ${patient != null ? "Scheduled soon" : "Not yet set"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      _buildVaccinationList(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDoctorCard(BuildContext context, PatientModel? patient) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFFCE4EC),
              child: Icon(Icons.medical_services, color: Color(0xFFF48FB1)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient?.doctorName ?? 'No Doctor Selected',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text('Consulting Pediatrician/OB-GYN', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  if (patient?.doctorName != null)
                    const Text('Assigned via Maternal Tracker', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makeCall(context, patient?.phone), 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationList() {
    final vaccines = [
      {'name': 'TT Dose 1', 'week': '12-16'},
      {'name': 'TT Dose 2', 'week': '20-24'},
      {'name': 'Flu Vaccine', 'week': 'Anytime'},
      {'name': 'Tdap', 'week': '27-36'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Required Vaccinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...vaccines.map((v) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.event_available, color: Color(0xFFF48FB1)),
                title: Text(v['name']!),
                subtitle: Text('Recommended week: ${v['week']}'),
                trailing: const Checkbox(value: false, onChanged: null),
              ),
            )),
      ],
    );
  }
}
