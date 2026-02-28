import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
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
  String _currentView = 'dashboard'; // dashboard, patients, opd

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
        title: Text(_currentView == 'dashboard' 
          ? SettingsController().translate('Doctor Dashboard') 
          : _currentView == 'patients' ? SettingsController().translate('Your Patients') : SettingsController().translate('OPD Appointments')),
        leading: _currentView != 'dashboard' 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _currentView = 'dashboard'),
            )
          : null,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(doctorName),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorHeader(doctorName),
          Expanded(
            child: _buildBody(doctorName),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String doctorName) {
    switch (_currentView) {
      case 'patients':
        return _buildPatientsView(doctorName);
      case 'opd':
        return _buildOPDView(doctorName);
      default:
        return _buildDashboardGrid();
    }
  }

  Widget _buildDashboardGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildDashboardCard(
            SettingsController().translate('Your Patients'), 
            Icons.people_outline, 
            () => setState(() => _currentView = 'patients')
          ),
          _buildDashboardCard(
            SettingsController().translate('OPD'), 
            Icons.calendar_today_outlined, 
            () => setState(() => _currentView = 'opd')
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shadowColor: Colors.pink.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsView(String doctorName) {
    return StreamBuilder<List<PatientModel>>(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: patients.length,
          itemBuilder: (context, index) => _buildPatientCard(patients[index]),
        );
      },
    );
  }

  Widget _buildOPDView(String doctorName) {
    return StreamBuilder<List<PatientModel>>(
      stream: PatientController().getPatientsForDoctor(doctorName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final today = DateTime.now().toString().split(' ')[0];
        final opdPatients = (snapshot.data ?? []).where((p) {
          return p.appointments.any((a) => a['date'] == today);
        }).toList();

        if (opdPatients.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No appointments scheduled for today.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: opdPatients.length,
          itemBuilder: (context, index) {
            final patient = opdPatients[index];
            final appointment = patient.appointments.firstWhere((a) => a['date'] == today);
            return _buildPatientCard(patient, subtitleOverride: 'Time: ${appointment['time']}');
          },
        );
      },
    );
  }

  Widget _buildDrawer(String doctorName) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person)),
                const SizedBox(height: 10),
                Text(doctorName, style: const TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentView = 'dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () => AuthController().signOut(context),
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

  Widget _buildPatientCard(PatientModel patient, {String? subtitleOverride}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.person, color: Colors.pink),
        ),
        title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitleOverride ?? 'Week: ${patient.pregnancyWeek} | ${patient.city}'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
