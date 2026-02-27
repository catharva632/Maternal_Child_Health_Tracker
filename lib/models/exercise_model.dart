class ExerciseModel {
  final String name;
  final String duration;
  final List<String> steps;
  final List<String> precautions;
  final String imagePath;

  ExerciseModel({
    required this.name,
    required this.duration,
    required this.steps,
    required this.precautions,
    required this.imagePath,
  });
}
