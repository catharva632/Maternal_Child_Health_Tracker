import 'package:tflite_v2/tflite_v2.dart';
import 'package:camera/camera.dart';

class MoodTrackerController {
  static final MoodTrackerController _instance = MoodTrackerController._internal();
  factory MoodTrackerController() => _instance;
  MoodTrackerController._internal();

  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    try {
      String? res = await Tflite.loadModel(
        model: "assets/models/emotion_model.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      print("Model loaded success: $res");
      _isModelLoaded = true;
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  Future<List<dynamic>?> runInferenceOnFrame(CameraImage image) async {
    if (!_isModelLoaded) await loadModel();
    
    try {
      return await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
    } catch (e) {
      print("Inference error: $e");
      return null;
    }
  }

  void dispose() {
    Tflite.close();
    _isModelLoaded = false;
  }

  /// Maps model labels to UI mood labels
  String mapDetectedMood(String detectedLabel) {
    // Expected labels in labels.txt:
    // 0 Angry
    // 1 Disgust
    // 2 Fear
    // 3 Happy
    // 4 Sad
    // 5 Surprise
    // 6 Neutral
    
    final label = detectedLabel.toLowerCase();
    if (label.contains('happy')) return 'Happy';
    if (label.contains('sad')) return 'Sad';
    if (label.contains('neutral')) return 'Energetic'; // Mapping neutral to Energetic for demo
    if (label.contains('fear') || label.contains('anxious')) return 'Anxious';
    if (label.contains('angry') || label.contains('irritated')) return 'Irritated';
    if (label.contains('surprise')) return 'Happy';
    
    return 'Happy'; // Default fallback
  }
}
