import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../models/patient_model.dart';

class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key});

  String _getBabySize(int week) {
    if (week < 5) return "Poppy seed";
    if (week < 9) return "Raspberry";
    if (week < 13) return "Lime";
    if (week < 17) return "Avocado";
    if (week < 21) return "Banana";
    if (week < 25) return "Ear of Corn";
    if (week < 29) return "Eggplant";
    if (week < 33) return "Squash";
    if (week < 37) return "Honeydew Melon";
    return "Watermelon";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PatientModel?>(
      stream: PatientController().getPatientStream(),
      builder: (context, snapshot) {
        final patient = snapshot.data;
        final week = patient?.pregnancyWeek ?? 0;
        final progress = (week / 40.0).clamp(0.0, 1.0);
        
        String trimester = "1st";
        if (week > 13) trimester = "2nd";
        if (week > 26) trimester = "3rd";

        return Scaffold(
          appBar: AppBar(title: const Text('Pregnancy Milestones')),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTopCard(context, week, trimester, progress),
                      const SizedBox(height: 20),
                      _buildFeatureList(context, [
                        {'title': 'DNA: Personalized Path', 'subtitle': 'Tailor your pregnancy journey', 'route': '/dnaMode', 'icon': Icons.fingerprint},
                        {'title': 'My Achievements', 'subtitle': 'View your badges & progress', 'route': '/badges', 'icon': Icons.emoji_events},
                        {'title': 'Weekly Development', 'subtitle': 'Week $week details', 'route': '/weeklyDevelopment', 'arguments': {'week': week}, 'icon': Icons.child_care},
                        {'title': 'Mood Tracker', 'subtitle': 'Emotional well-being', 'route': '/moodTracker', 'icon': Icons.mood},
                        {'title': 'Cultural Wisdom', 'subtitle': 'Traditional tips & facts', 'route': '/culturalWisdom', 'icon': Icons.brightness_high},
                        {'title': 'Milestone Timeline', 'subtitle': 'View your progress', 'route': null, 'icon': Icons.timeline},
                      ]),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTopCard(BuildContext context, int week, String trimester, double progress) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Week $week', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('$trimester Trimester', style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 10),
            Text('Baby size: ${_getBabySize(week)}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              color: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.3),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context, List<Map<String, dynamic>> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final bool isDna = item['title'].toString().contains('DNA');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDna ? Theme.of(context).colorScheme.primaryContainer : null,
          child: ListTile(
            leading: Icon(item['icon'], color: isDna ? Theme.of(context).colorScheme.primary : null),
            title: Text(item['title'], style: TextStyle(fontWeight: isDna ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(item['subtitle']),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (item['route'] != null) {
                Navigator.pushNamed(
                  context, 
                  item['route'], 
                  arguments: item['arguments']
                );
              }
            },
          ),
        );
      },
    );
  }
}
