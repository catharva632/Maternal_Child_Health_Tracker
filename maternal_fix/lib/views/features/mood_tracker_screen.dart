import 'package:flutter/material.dart';
import '../../controllers/gamification_controller.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String? _selectedMood;
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '😤', 'label': 'Irritated'},
    {'emoji': '✨', 'label': 'Energetic'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildMoodGrid(),
            if (_selectedMood != null) ...[
              const SizedBox(height: 32),
              _buildInsightCard(),
            ],
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _moods.length,
      itemBuilder: (context, index) {
        final mood = _moods[index];
        final isSelected = _selectedMood == mood['label'];
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood['label']),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mood['emoji'], style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  mood['label'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightCard() {
    final insight = _getMoodInsight(_selectedMood!);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text("Mood Insight", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Effect on Baby:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            Text(insight['effect']!),
            const SizedBox(height: 16),
            const Text(
              "How to Improve:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            Text(insight['improvement']!),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _selectedMood == null ? null : () async {
          await GamificationController().unlockBadge('mood_logger');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mood logged! Baby is grateful for your care. ✨')),
            );
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text("Save Mood", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Map<String, String> _getMoodInsight(String mood) {
    switch (mood) {
      case 'Happy':
      case 'Energetic':
        return {
          'effect': 'Positive vibes release "feel-good" hormones like serotonin, which help in baby\'s brain development and keep the heart rate stable.',
          'improvement': 'Keep doing what makes you happy! Share this joy with your partner or a friend.'
        };
      case 'Anxious':
      case 'Irritated':
        return {
          'effect': 'High stress can temporarily increase baby\'s heart rate. Calmness is key for a steady environment.',
          'improvement': 'Try the 4-7-8 breathing technique. List 3 things you are grateful for today.'
        };
      case 'Sad':
      case 'Tired':
        return {
          'effect': 'Baby can sense your energy levels. Resting helps both you and the baby conserve energy for growth.',
          'improvement': 'Take a short walk in nature, listen to soothing music, or have a warm cup of herbal tea.'
        };
      default:
        return {
          'effect': 'Your emotional state is unique and valid.',
          'improvement': 'Focus on self-care and gentle movement today.'
        };
    }
  }
}
