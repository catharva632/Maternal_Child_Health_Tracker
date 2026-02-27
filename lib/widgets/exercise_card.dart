import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../models/exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const ExerciseCard({super.key, required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: exercise.imagePath.startsWith('http')
            ? Image.network(
                exercise.imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : Image.asset(
                exercise.imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              ),
        ),
        title: Text(SettingsController().tr(exercise.name), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(SettingsController().tr(exercise.duration)),
        trailing: const Icon(Icons.play_circle_outline, color: Color(0xFFF48FB1)),
        onTap: onTap,
      ),
    );
  }
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.pink.shade50,
      child: const Icon(Icons.fitness_center, color: Color(0xFFF48FB1)),
    );
  }
}
