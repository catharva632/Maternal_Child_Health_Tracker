import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/patient_model.dart';

class HospitalScheduleScreen extends StatefulWidget {
  const HospitalScheduleScreen({super.key});

  @override
  State<HospitalScheduleScreen> createState() => _HospitalScheduleScreenState();
}

class _HospitalScheduleScreenState extends State<HospitalScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PatientModel?>(
      stream: PatientController().getPatientStream(),
      builder: (context, snapshot) {
        final patient = snapshot.data;
        final week = patient?.pregnancyWeek ?? 0;
        final doctorName = patient?.doctorName ?? "Not Assigned";
        final hospitalName = patient?.hospitalName ?? "Not Assigned";
        final doctorPhone = patient?.doctorPhone ?? "";
        final hospitalPhone = patient?.hospitalPhone ?? "";
        final hospitalAddress = patient?.hospitalAddress ?? "Pune, Maharashtra";
        final hospitalLocation = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$hospitalName $hospitalAddress')}";

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildDoctorCard(patient, doctorName, hospitalName, doctorPhone, hospitalLocation, week),
                const SizedBox(height: 20),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                        controller: _tabController,
                    children: [
                       _buildVisitsTab(week),
                       _buildVaccinationTab(week, patient?.vaccinations ?? []),
                       _buildHospitalInfoTab(doctorName, hospitalName, hospitalPhone, hospitalAddress, hospitalLocation),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDoctorCard(PatientModel? patient, String doctorName, String hospitalName, String doctorPhone, String hospitalLocation, int week) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)], // Professional Deep Pink to Crimson
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SettingsController().tr('Your Doctor'),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${SettingsController().tr('Week')} $week',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            doctorName,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            hospitalName,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const Spacer(),
          Text(
            SettingsController().tr('Next Appointment'),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            SettingsController().tr(_getNextAppointmentDate(patient?.appointments ?? [])),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makeCall(doctorPhone),
                  icon: const Icon(Icons.call, size: 18),
                  label: Text(SettingsController().tr('Call Doctor')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(hospitalLocation),
                  icon: const Icon(Icons.local_hospital, size: 18),
                  label: Text(SettingsController().tr('View Hospital')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFFE91E63),
            borderRadius: BorderRadius.circular(25),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: SettingsController().tr('Doctor Visits')),
            Tab(text: SettingsController().tr('Vaccination')),
            Tab(text: SettingsController().tr('Hospital Info')),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitsTab(int currentWeek) {
    final visitData = [
      {'name': 'Week 8 Visit', 'week': 8},
      {'name': 'Week 12 Visit', 'week': 12},
      {'name': 'Week 20 Anatomy Scan', 'week': 20},
      {'name': 'Week 28 Visit', 'week': 28},
      {'name': 'Week 36 Visit', 'week': 36},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitData.length,
      itemBuilder: (context, index) {
        final visit = visitData[index];
        final int targetWeek = visit['week'] as int;
        
        String status;
        IconData icon;
        Color iconColor;

        if (currentWeek >= targetWeek) {
          status = SettingsController().tr('Completed');
          icon = Icons.check_circle;
          iconColor = Colors.green;
        } else if (targetWeek - currentWeek <= 2) {
          status = SettingsController().tr('Upcoming');
          icon = Icons.access_time_filled;
          iconColor = Colors.orange;
        } else {
          status = SettingsController().tr('Pending');
          icon = Icons.radio_button_unchecked;
          iconColor = Colors.grey;
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(SettingsController().tr(visit['name'] as String), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(status, style: TextStyle(color: iconColor)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationTab(int currentWeek, List<Map<String, String>> customVaccines) {
    bool isCompleted(String time) {
      if (time == '1st Trimester') return currentWeek >= 1;
      if (time == '2nd Trimester') return currentWeek >= 14;
      if (time == '3rd Trimester') return currentWeek >= 27;
      return false;
    }

    final motherVaccines = [
      {'name': 'COVID-19 Vaccine', 'time': '1st Trimester', 'desc': 'Safe at any time'},
      {'name': 'Tetanus Toxoid (TT) 1', 'time': '1st Trimester', 'desc': 'On confirmation'},
      {'name': 'Influenza (Flu) Shot', 'time': '1st Trimester', 'desc': 'Inactivated vaccine'},
      {'name': 'Tetanus Toxoid (TT) 2', 'time': '2nd Trimester', 'desc': '4 weeks after TT1'},
      {'name': 'Tdap Vaccine', 'time': '3rd Trimester', 'desc': '27-36 weeks'},
      {'name': 'RSV Vaccine', 'time': '3rd Trimester', 'desc': '32-36 weeks'},
    ];

    final childVaccines = [
      {'name': 'BCG', 'time': 'Birth', 'desc': 'Tuberculosis protection'},
      {'name': 'Hepatitis B (1st dose)', 'time': 'Birth', 'desc': 'Liver infection prevention'},
      {'name': 'OPV-0', 'time': 'Birth', 'desc': 'Oral Polio Vaccine'},
      {'name': 'Pentavalent - 1', 'time': '6 Weeks', 'desc': 'DPT, HepB, Hib'},
      {'name': 'OPV-1', 'time': '6 Weeks', 'desc': '2nd dose polio'},
      {'name': 'Rotavirus - 1', 'time': '6 Weeks', 'desc': 'Diarrhea protection'},
      {'name': 'PCV - 1', 'time': '6 Weeks', 'desc': 'Pneumonia protection'},
      {'name': 'Pentavalent - 2', 'time': '10 Weeks', 'desc': '2nd dose'},
      {'name': 'OPV-2', 'time': '10 Weeks', 'desc': '3rd dose polio'},
      {'name': 'Rotavirus - 2', 'time': '10 Weeks', 'desc': '2nd dose'},
      {'name': 'PCV - 2', 'time': '10 Weeks', 'desc': '2nd dose'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (customVaccines.isNotEmpty) ...[
          _buildSectionTitle(SettingsController().tr("Doctor's Prescribed Vaccinations")),
          ...customVaccines.map((v) => _buildVaccineCard({
                'name': v['name'] ?? 'Unknown',
                'time': v['date'] ?? 'No date',
                'desc': SettingsController().tr('Scheduled by your doctor'),
              }, checked: false)),
          const SizedBox(height: 24),
        ],
        _buildSectionTitle(SettingsController().tr("Mother's Vaccination Schedule")),
        ...motherVaccines.map((v) => _buildVaccineCard(v, checked: isCompleted(v['time']!))),
        const SizedBox(height: 24),
        _buildSectionTitle(SettingsController().tr("Child's Vaccination Schedule (Birth - 3 Months)")),
        ...childVaccines.map((v) => _buildVaccineCard(v, isChild: true, checked: false)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE91E63).withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildVaccineCard(Map<String, String> v, {bool isChild = false, bool checked = false}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isChild ? Colors.blue : const Color(0xFFE91E63)).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isChild ? Icons.child_care : Icons.vaccines,
            color: isChild ? Colors.blue : const Color(0xFFE91E63),
          ),
        ),
        title: Text(SettingsController().tr(v['name']!), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${SettingsController().tr(v['time']!)} • ${SettingsController().tr(v['desc']!)}'),
        trailing: Checkbox(
          value: checked,
          onChanged: (val) {},
          activeColor: const Color(0xFFE91E63),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildHospitalInfoTab(String doctorName, String hospitalName, String hospitalPhone, String hospitalAddress, String hospitalLocation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(SettingsController().tr('Doctor Name:'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Text(SettingsController().tr('Hospital:'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(hospitalName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Text(SettingsController().tr('Phone:'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(hospitalPhone.isEmpty ? SettingsController().tr('Not Available') : hospitalPhone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Text(SettingsController().tr('Address:'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(hospitalAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _makeCall(hospitalPhone),
                      icon: const Icon(Icons.call),
                      label: Text(SettingsController().tr('Call')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF48FB1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(hospitalLocation),
                      icon: const Icon(Icons.map),
                      label: Text(SettingsController().tr('Open Map')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF48FB1),
                        side: const BorderSide(color: Color(0xFFF48FB1)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextAppointmentDate(List<Map<String, String>> appointments) {
    if (appointments.isEmpty) return 'Scheduled Soon';
    final today = DateTime.now().toString().split(' ')[0];
    final upcoming = appointments.where((a) => (a['date'] ?? '').compareTo(today) >= 0).toList();
    if (upcoming.isEmpty) return 'No Upcoming';
    upcoming.sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
    return upcoming.first['date'] ?? 'Scheduled Soon';
  }
}
