import 'package:flutter/material.dart';
import '../../controllers/patient_controller.dart';
import '../../models/patient_model.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  final List<Map<String, dynamic>> _allBadges = const [
    {'id': 'healthy_diet', 'title': 'Healthy Diet Week', 'icon': Icons.restaurant, 'color': Colors.green},
    {'id': 'kick_tracker', 'title': 'Kick Tracker Champion', 'icon': Icons.sports_score, 'color': Colors.orange},
    {'id': 'calm_mind', 'title': 'Calm Mind Star', 'icon': Icons.auto_awesome, 'color': Colors.blue},
    {'id': 'dna_dna', 'title': 'DNA Path Pioneer', 'icon': Icons.fingerprint, 'color': Colors.purple},
    {'id': 'mood_logger', 'title': 'Mindful Mother', 'icon': Icons.favorite, 'color': Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Achievements')),
      body: StreamBuilder<PatientModel?>(
        stream: PatientController().getPatientStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final unlockedIds = snapshot.data?.badges ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: _allBadges.length,
            itemBuilder: (context, index) {
              final badge = _allBadges[index];
              final isUnlocked = unlockedIds.contains(badge['id']);

              return Card(
                elevation: isUnlocked ? 4 : 0,
                color: isUnlocked ? Colors.white : Colors.grey.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: isUnlocked ? BorderSide(color: badge['color'], width: 2) : BorderSide.none),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked ? badge['color'].withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge['icon'],
                        size: 40,
                        color: isUnlocked ? badge['color'] : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        badge['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.black87 : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked ? "Unlocked!" : "Locked",
                      style: TextStyle(
                        color: isUnlocked ? badge['color'] : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
