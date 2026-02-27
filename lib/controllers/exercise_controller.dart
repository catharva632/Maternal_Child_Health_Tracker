import '../models/exercise_model.dart';

class ExerciseController {
  List<ExerciseModel> getExercises(int week) {
    return [
      ExerciseModel(
        name: 'Walking',
        duration: '20-30 mins',
        steps: [
          'Wear comfortable, supportive shoes.',
          'Walk at a steady, rhythmic pace.',
          'Swing your arms naturally.',
          'Keep your back straight and chin up.'
        ],
        precautions: [
          'Stay hydrated.',
          'Avoid walking in extreme heat.',
          'Stop if you feel dizzy or short of breath.'
        ],
        imagePath: 'assets/images/walking.jpeg',
        videoId: 'Qd4QBIoKrJM',
      ),
      ExerciseModel(
        name: 'Swimming',
        duration: '20 mins',
        steps: [
          'Choose a gentle stroke like breaststroke.',
          'Use the water to support your weight.',
          'Focus on slow, rhythmic breathing.',
          'Relax your muscles into the water.'
        ],
        precautions: [
          'Don\'t hold your breath for too long.',
          'Ensure the water temperature is comfortable.',
          'Watch out for slippery pool decks.'
        ],
        imagePath: 'assets/images/swimming.jpeg',
        videoId: 'VyF5J5yXTxI',
      ),
      ExerciseModel(
        name: 'Prenatal Yoga',
        duration: '15-20 mins',
        steps: [
          'Set up a comfortable yoga mat.',
          'Focus on gentle stretches and flexibility.',
          'Engage in deep belly breathing.',
          'End with a few minutes of relaxation.'
        ],
        precautions: [
          'Avoid lying flat on your back after the first trimester.',
          'Don\'t overstretch joints; focus on muscle tone.',
          'Avoid hot yoga.'
        ],
        imagePath: 'assets/images/parental yoga.jpeg',
        videoId: 'B87FpWtkIKA',
      ),
      ExerciseModel(
        name: 'Squats',
        duration: '3 sets of 10',
        steps: [
          'Stand with feet shoulder-width apart.',
          'Lower your hips as if sitting in a chair.',
          'Keep your heels flat on the floor.',
          'Push through your heels to stand up.'
        ],
        precautions: [
          'Use a chair for balance if needed.',
          'Keep your back straight.',
          'Stop if you feel pressure in your pelvis.'
        ],
        imagePath: 'assets/images/squats.jpeg',
        videoId: 'baCXyqhmuN4',
      ),
      ExerciseModel(
        name: 'Kegels',
        duration: '10 reps, 3 times',
        steps: [
          'Identify your pelvic floor muscles.',
          'Squeeze and hold for 3-5 seconds.',
          'Relax for 3-5 seconds.',
          'Focus on not tightening your abs or thighs.'
        ],
        precautions: [
          'Don\'t do them while urinating (can cause UTIs).',
          'Ensure you breathe normally while squeezing.'
        ],
        imagePath: 'assets/images/kegels.jpeg',
        videoId: 'nBfbJ-3tUdc',
      ),
      ExerciseModel(
        name: 'Cat-Cow Stretch',
        duration: '10-12 reps',
        steps: [
          'Get on your hands and knees.',
          'Inhale and drop your belly (Cow).',
          'Exhale and arch your back (Cat).',
          'Move slowly with your breath.'
        ],
        precautions: [
          'Avoid excessive arching of the back.',
          'Keep your movements fluid and gentle.'
        ],
        imagePath: 'assets/images/cat cow stretch.jpeg',
        videoId: '9uY-vvV4Lgc',
      ),
      ExerciseModel(
        name: 'Modified Push-ups',
        duration: '2 sets of 8',
        steps: [
          'Place your hands against a wall or get on your knees.',
          'Lower your chest towards the surface.',
          'Keep your core engaged but not strained.',
          'Push back to the starting position.'
        ],
        precautions: [
          'Avoid any strain on your abdominal wall.',
          'Perform them slowly to maintain control.'
        ],
        imagePath: 'assets/images/modified push ups.jpeg',
        videoId: 'XEs0XQuOpO4',
      ),
    ];
  }
}
