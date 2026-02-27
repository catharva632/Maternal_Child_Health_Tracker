import 'package:tflite_v2/tflite_v2.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<List<dynamic>?> runInferenceOnFrame(CameraImage image, {int rotation = 90}) async {
    if (!_isModelLoaded) await loadModel();
    
    try {
      final results = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: rotation,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      
      if (results == null) {
        debugPrint("Inference returned NULL results for rotation $rotation");
      } else if (results.isEmpty) {
        debugPrint("Inference returned EMPTY results for rotation $rotation");
      } else {
        debugPrint("Inference results (rot $rotation): $results");
      }
      
      return results;
    } catch (e) {
      debugPrint("Inference error at rotation $rotation: $e");
      return null;
    }
  }

  void dispose() {
    Tflite.close();
    _isModelLoaded = false;
  }

  Future<void> saveMood(String mood) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .add({
      'mood': mood,
      'timestamp': FieldValue.serverTimestamp(),
    });
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
