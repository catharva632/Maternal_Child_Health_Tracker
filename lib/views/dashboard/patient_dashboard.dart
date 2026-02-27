import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/patient_model.dart';
import 'package:intl/intl.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController().themeMode,
      builder: (context, mode, child) {
        return StreamBuilder<PatientModel?>(
          stream: PatientController().getPatientStream(),
          builder: (context, snapshot) {
            final patient = snapshot.data;
            
            return Scaffold(
              appBar: AppBar(
                title: const Text('Maternal Tracker'),
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              ),
              endDrawer: _buildDrawer(context, patient, mode == ThemeMode.dark),
              endDrawerEnableOpenDragGesture: true,
              body: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeader(context, patient),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              children: [
                                _buildDashboardCard(context, 'Pregnancy\nMilestones', Icons.auto_graph, '/milestones'),
                                _buildDashboardCard(context, 'Hospital &\nVaccination', Icons.vaccines, '/hospital'),
                                _buildDashboardCard(context, 'Chatbot', Icons.chat_bubble_outline, '/chatbot'),
                                _buildDashboardCard(context, 'Exercise &\nDiet', Icons.restaurant_menu, '/exercise'),
                                _buildDashboardCard(context, 'My Contacts', Icons.contact_phone_outlined, '/contacts'),
                                _buildDashboardCard(context, 'Emergency\nHelpline', Icons.emergency, '/emergencyMap'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          }
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PatientModel? patient) {
    final String name = patient?.name ?? "User";
    final int week = patient?.pregnancyWeek ?? 0;
    final double progress = (week / 40.0).clamp(0.0, 1.0);
    
    String trimester = "1st";
    if (week > 13) trimester = "2nd";
    if (week > 26) trimester = "3rd";
    
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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('$week Weeks Pregnant', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('Trimester: $trimester', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (patient?.doctorName != null)
                      Text('Doctor: ${patient!.doctorName}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ProfileController().uploadProfilePicture(context),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: patient?.photoUrl != null 
                        ? NetworkImage(patient!.photoUrl!) 
                        : null,
                      child: patient?.photoUrl == null 
                        ? const Icon(Icons.person, size: 40, color: Colors.white) 
                        : null,
                    ),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Icon(Icons.add_a_photo, size: 15, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pregnancy Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
                minHeight: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, PatientModel? patient, bool isDark) {
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
                Text(patient?.name ?? 'Menu', style: const TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),
          _buildDrawerItem(context, 'Settings', Icons.settings, '/settings'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (val) => ThemeController().toggleTheme(val),
            ),
          ),
          _buildDrawerItem(context, 'Generate Report', Icons.picture_as_pdf_outlined, '/report'),
          _buildDrawerItem(context, 'About', Icons.info_outline, '/about'),
          _buildDrawerItem(context, 'My Contacts', Icons.contact_phone_outlined, '/contacts'),
          _buildDrawerItem(context, 'Emergency Map', Icons.map_outlined, '/emergencyMap'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => AuthController().signOut(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
