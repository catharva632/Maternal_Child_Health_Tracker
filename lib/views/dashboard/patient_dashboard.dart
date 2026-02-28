import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/patient_model.dart';
import 'package:intl/intl.dart';
import 'package:flip_card/flip_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

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
                title: Text(SettingsController().tr('Pregnancy Progress')),
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
                                _buildDashboardCard(context, SettingsController().tr('Milestones'), Icons.auto_graph, '/milestones'),
                                _buildDashboardCard(context, SettingsController().tr('Hospital Schedule'), Icons.vaccines, '/hospital'),
                                _buildDashboardCard(context, SettingsController().tr('Ask AI Assistant'), Icons.chat_bubble_outline, '/chatbot'),
                                _buildDashboardCard(context, SettingsController().tr('Exercise & Diet'), Icons.restaurant_menu, '/exercise'),
                                 _buildDashboardCard(context, SettingsController().tr('Emergency Map'), Icons.emergency, '/emergencyMap'),
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
    
    // Generate QR Data string
    final Map<String, dynamic> qrData = {
      'abhaId': patient?.abhaId ?? 'N/A',
      'name': name,
      'weeks': week,
      'bloodGroup': patient?.bloodGroup ?? 'N/A',
      'weight': '${patient?.weight ?? 0} kg',
      'height': '${patient?.height ?? 0} cm',
      'allergies': patient?.allergies ?? 'None',
    };
    final String qrString = jsonEncode(qrData);

    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width * 0.05;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          FlipCard(
            fill: Fill.fillBack,
            direction: FlipDirection.HORIZONTAL,
            front: _buildProfileFront(context, patient, name, week, trimester),
            back: _buildProfileBack(context, qrString),
          ),
          SizedBox(height: size.height * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(SettingsController().tr('Pregnancy Progress'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
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
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: ProfileController.getImageProvider(patient?.photoUrl),
                  child: patient?.photoUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(height: 10),
                Text(patient?.name ?? 'Menu', style: const TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),
          const Divider(),
          _buildDrawerItem(context, SettingsController().tr('Profile'), Icons.person_outline, '/profile'),
          _buildDrawerItem(context, SettingsController().tr('My Contacts'), Icons.contact_phone_outlined, '/contacts'),
          _buildDrawerItem(context, SettingsController().tr('Generate Report'), Icons.picture_as_pdf_outlined, '/report'),
          _buildDrawerItem(context, SettingsController().tr('Settings'), Icons.settings, '/settings'),
          _buildDrawerItem(context, SettingsController().tr('About'), Icons.info_outline, '/about'),
          SwitchListTile(
            title: Text(SettingsController().tr('Dark Mode')),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            value: isDark,
            onChanged: (bool value) {
              ThemeController().toggleTheme(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(SettingsController().tr('Logout'), style: const TextStyle(color: Colors.red)),
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

  Widget _buildProfileFront(BuildContext context, PatientModel? patient, String name, int week, String trimester) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text('$week ${SettingsController().tr('Weeks Pregnant')}', style: TextStyle(color: Theme.of(context).hintColor)),
              const SizedBox(height: 8),
              Text('${SettingsController().tr('Trimester')}: $trimester', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (patient?.doctorName != null)
                Text('${SettingsController().tr('Doctor')}: ${patient!.doctorName}', 
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.flip, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(SettingsController().tr('Tap to see QR'), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
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
                backgroundImage: ProfileController.getImageProvider(patient?.photoUrl),
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
    );
  }

  Widget _buildProfileBack(BuildContext context, String qrString) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(SettingsController().tr('Patient QR Code'), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                Text(SettingsController().tr('Scan for Medical Details'), 
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.flip, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Tap to flip back', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          QrImageView(
            data: qrString,
            version: QrVersions.auto,
            size: 100.0,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
