import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/patient_model.dart';
import 'patient_edit_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  Map<String, dynamic>? _doctorProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthController().getDoctorProfile();
    if (mounted) {
      setState(() {
        _doctorProfile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final doctorName = _doctorProfile?['name'] ?? "Doctor";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => AuthController().signOut(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorHeader(doctorName),
          StreamBuilder<List<PatientModel>>(
            stream: PatientController().getPatientsForDoctor(doctorName),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              final today = DateTime.now().toString().split(' ')[0];
              final patientsToday = snapshot.data!.where((p) {
                return p.appointments.any((a) => a['date'] == today);
              }).toList();

              if (patientsToday.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      "Today's Schedule",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFAD1457)),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: patientsToday.length,
                      itemBuilder: (context, index) {
                        final patient = patientsToday[index];
                        final appointment = patient.appointments.firstWhere((a) => a['date'] == today);
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.pink.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(appointment['time'] ?? 'No time', style: const TextStyle(color: Colors.pink, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 30, indent: 20, endIndent: 20),
                ],
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Your Patients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PatientModel>>(
              stream: PatientController().getPatientsForDoctor(doctorName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final patients = snapshot.data ?? [];
                if (patients.isEmpty) {
                  return const Center(child: Text('No patients assigned yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: patients.length,
                  itemBuilder: (context, index) => _buildPatientCard(patients[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome,',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          Text(
            'Dr. $name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _doctorProfile?['specialization'] ?? 'Medical Professional',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.person, color: Colors.pink),
        ),
        title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Week: ${patient.pregnancyWeek} | ${patient.city}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientEditScreen(patient: patient),
            ),
          );
        },
      ),
    );
  }
}
