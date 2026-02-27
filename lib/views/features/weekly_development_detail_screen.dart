import 'package:flutter/material.dart';

class WeeklyDevelopmentDetailScreen extends StatelessWidget {
  final int week;

  const WeeklyDevelopmentDetailScreen({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    // Sample data - In a real app, this would be a full database or JSON
    final Map<String, dynamic> weekData = _getWeekData(week);

    return Scaffold(
      appBar: AppBar(title: Text('Week $week Development')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, "Baby's Development", Icons.child_care),
            const SizedBox(height: 12),
            _buildInfoCard(context, weekData['babyDevelopments']),
            const SizedBox(height: 24),
            _buildSectionHeader(context, "Mother's Body Changes", Icons.woman),
            const SizedBox(height: 12),
            _buildInfoCard(context, weekData['motherChanges']),
            const SizedBox(height: 24),
            _buildSectionHeader(context, "Weekly Tips", Icons.tips_and_updates),
            const SizedBox(height: 12),
            _buildInfoCard(context, weekData['tips']),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, List<String> details) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: details.map((detail) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Expanded(child: Text(detail, style: const TextStyle(fontSize: 16))),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Map<String, dynamic> _getWeekData(int week) {
    // Default generic data if specific week isn't defined
    if (week == 24) {
      return {
        'babyDevelopments': [
          "Baby’s lungs are developing rapidly.",
          "Taste buds are forming.",
          "Baby responds to sounds from outside.",
          "Eyebrows and eyelashes are now visible.",
          "Brain growth is increasing significantly."
        ],
        'motherChanges': [
          "Back pain may increase as your center of gravity shifts.",
          "Mild swelling in feet and ankles (edema).",
          "Increased appetite as baby grows.",
          "Skin stretching on abdomen and breasts.",
          "Baby kicks are becoming much stronger."
        ],
        'tips': [
          "Stay hydrated to help with swelling.",
          "Practice prenatal yoga for back pain.",
          "Talk or sing to your baby - they can hear you!"
        ]
      };
    }

    // Generic week template
    return {
      'babyDevelopments': [
        "Major organs are continuing to mature.",
        "Baby is gaining weight to build protective fat.",
        "Movement is becoming more coordinated.",
        "Brain neurons are connecting at a fast pace."
      ],
      'motherChanges': [
        "You may experience increased fatigue.",
        "Occasional ligament pain as your uterus expands.",
        "Glow may be more visible due to increased blood flow.",
        "Need for more frequent rests and hydration."
      ],
      'tips': [
        "Eat small, frequent meals for energy.",
        "Keep up with your prenatal vitamins.",
        "Rest with your feet elevated if they feel tired."
      ]
    };
  }
}
