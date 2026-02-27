import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../controllers/gamification_controller.dart';
import '../../controllers/mood_tracker_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String? _selectedMood;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  String _scanStatus = "Scan your face for AI mood detection";
  final _aiController = MoodTrackerController();

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '😤', 'label': 'Irritated'},
    {'emoji': '✨', 'label': 'Energetic'},
  ];

  @override
  void initState() {
    super.initState();
    _aiController.loadModel();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use front camera if available
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _startScanning() async {
    if (!_isCameraInitialized) {
      await _initializeCamera();
    }
    
    if (!_isCameraInitialized) return;

    setState(() {
      _isScanning = true;
      _scanStatus = "Analyzing facial expressions...";
    });

    int frameCount = 0;
    _cameraController!.startImageStream((image) async {
      frameCount++;
      // Only run inference every 15 frames to save resources
      if (frameCount % 15 == 0) {
        final results = await _aiController.runInferenceOnFrame(image);
        if (results != null && results.isNotEmpty) {
          final topResult = results[0];
          final detectedMoodLabel = topResult['label'];
          final confidence = topResult['confidence'];

          if (confidence > 0.5 && mounted) {
            final mappedMood = _aiController.mapDetectedMood(detectedMoodLabel);
            _cameraController!.stopImageStream();
            setState(() {
              _selectedMood = mappedMood;
              _isScanning = false;
              _isCameraInitialized = false;
              _scanStatus = "Detected: $mappedMood (${(confidence * 100).toStringAsFixed(0)}%)";
            });
            _cameraController?.dispose();
            _cameraController = null;
          }
        }
      }
    });

    // Timeout after 10 seconds if nothing detected
    Future.delayed(const Duration(seconds: 10), () {
      if (_isScanning && mounted) {
        _cameraController?.stopImageStream();
        setState(() {
          _isScanning = false;
          _isCameraInitialized = false;
          _scanStatus = "Scan timed out. Try again or select manually.";
        });
        _cameraController?.dispose();
        _cameraController = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Mood Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _scanStatus,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            
            // Camera / AI Section
            if (_isScanning && _isCameraInitialized)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              )
            else
              _buildScanButton(),
              
            const SizedBox(height: 32),
            const Text("Manual Selection", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
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

  Widget _buildScanButton() {
    return InkWell(
      onTap: _startScanning,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_retouching_natural, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text("AI Scan Face", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
