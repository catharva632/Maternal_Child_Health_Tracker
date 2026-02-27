import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import '../../controllers/gamification_controller.dart';
import '../../controllers/mood_tracker_controller.dart';
import '../../controllers/settings_controller.dart';
import 'package:permission_handler/permission_handler.dart';

enum MoodScanState { initial, scanning, result }

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  MoodScanState _currentState = MoodScanState.initial;
  String? _detectedMood;
  CameraController? _cameraController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isCameraInitialized = false;
  final _aiController = MoodTrackerController();
  FlashMode _flashMode = FlashMode.off;

  final Map<String, String> _moodEmojis = {
    'Happy': '😊',
    'Sad': '😔',
    'Anxious': '😰',
    'Tired': '😴',
    'Irritated': '😤',
    'Energetic': '✨',
  };

  String? _currentDetectedLabel;
  double _currentConfidence = 0.0;
  
  // Debug rotation handling
  int _debugRotation = 270; // Start with 270 which is common for front cameras
  final List<int> _rotationOptions = [0, 90, 180, 270];

  @override
  void initState() {
    super.initState();
    _aiController.loadModel();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // existing implementation unchanged
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
        _startImageStream();
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('video/WhatsApp Video 2026-02-27 at 10.07.37 PM.mp4');
    try {
      await _videoController!.initialize();
      _videoController!.setLooping(false);
      await _videoController!.play();
      
      if (mounted) {
        setState(() => _isVideoInitialized = true);
        
        // Simulate detection after 5 seconds of video
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _currentState == MoodScanState.scanning && _isVideoInitialized) {
            _processAutoDetection("Neutral"); // Simulate a detection
          }
        });
      }
    } catch (e) {
      debugPrint("Video init error: $e");
    }
  }

  

  void _startImageStream() {
    int frameCount = 0;
    int detections = 0;
    
    _cameraController!.startImageStream((image) async {
      frameCount++;
      if (frameCount % 10 == 0 && _currentState == MoodScanState.scanning) { 
        // Use the debug rotation override
        final results = await _aiController.runInferenceOnFrame(
          image, 
          rotation: _debugRotation
        );
        if (results != null && results.isNotEmpty && mounted) {
          final label = results[0]['label'];
          final confidence = results[0]['confidence'];

          setState(() {
            _currentDetectedLabel = label;
            _currentConfidence = confidence;
          });

          // Auto-trigger if confidence is high enough for a steady detection
          if (confidence > 0.45) {
            detections++;
            if (detections >= 2) { // Need 2 steady frames to confirm
              _processAutoDetection(label);
            }
          } else {
            detections = 0;
          }
        }
      }
    });
  }

  void _processAutoDetection(String label) async {
    if (!mounted || _currentState != MoodScanState.scanning) return;

    setState(() {
      _detectedMood = _aiController.mapDetectedMood(label);
      _currentState = MoodScanState.result;
    });

    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _cameraController = null;
    _isCameraInitialized = false;
  }

  void _startScan() async {
    // Use camera for live scan
    await _initializeCamera();
    if (_isCameraInitialized) {
      setState(() => _currentState = MoodScanState.scanning);
    }
  }

  void _startVideoScan() async {
    await _initializeVideo();
    if (_isVideoInitialized) {
      setState(() => _currentState = MoodScanState.scanning);
    }
  }


  void _resetScan() {
    setState(() {
      _currentState = MoodScanState.initial;
      _detectedMood = null;
      _currentConfidence = 0.0;
      _currentDetectedLabel = null;
      // We don't reset _debugRotation, so user keeps their verified setting
    });
  }

  void _cycleRotation() {
    setState(() {
      int currentIndex = _rotationOptions.indexOf(_debugRotation);
      _debugRotation = _rotationOptions[(currentIndex + 1) % _rotationOptions.length];
      _currentConfidence = 0.0; // Reset confidence to see if new rotation works better
      _currentDetectedLabel = null;
    });
    debugPrint("Switched AI Rotation to: $_debugRotation");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(SettingsController().tr('AI Mood Tracker')),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case MoodScanState.initial:
        return _buildInitialView();
      case MoodScanState.scanning:
        return _buildCameraView();
      case MoodScanState.result:
        return _buildResultView();
    }
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mood_rounded, size: 100, color: Color(0xFFF48FB1)),
            const SizedBox(height: 32),
            Text(
              SettingsController().tr("How are you feeling Today?"),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              SettingsController().tr("Scan your face for AI mood detection"),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 60),
            _buildActionButton(
              onPressed: _startScan,
              label: SettingsController().tr("AI Scan Face"),
              icon: Icons.face_retouching_natural,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              onPressed: _startVideoScan,
              label: SettingsController().tr("Use Sample Video"),
              icon: Icons.video_library,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized && !_isVideoInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_isCameraInitialized && _cameraController != null) {
      return Stack(
        children: [
          // Full screen camera
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
          // Scan Overlay UI
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 40),
              ),
              child: Center(
                child: Container(
                  width: 250,
                  height: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          // Bottom Controls
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  _currentConfidence > 0.3 ? SettingsController().tr("Face Detected! Analyzing...") : SettingsController().tr("Center your face in the frame"),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, shadows: [Shadow(blurRadius: 10)]),
                ),
                const SizedBox(height: 10),
                Text(
                  SettingsController().tr("Keep still for a moment"),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Debug Info and Rotation Cycle Button
          Positioned(
            top: 60,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_currentDetectedLabel != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Debug: $_currentDetectedLabel (${(_currentConfidence * 100).toStringAsFixed(1)}%)",
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _cycleRotation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.screen_rotation, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "AI Rot: $_debugRotation°",
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Back Button
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: _resetScan,
            ),
          ),
        ],
      );
    } else if (_isVideoInitialized && _videoController != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          // Scan Overlay UI
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 40),
              ),
              child: Center(
                child: Container(
                  width: 250,
                  height: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
          // Bottom Controls
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  SettingsController().tr("Analyzing Video Feed..."),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, shadows: [Shadow(blurRadius: 10)]),
                ),
                const SizedBox(height: 10),
                Text(
                  SettingsController().tr("AI processing in progress"),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Back Button
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: _resetScan,
            ),
          ),
        ],
      );
    }
    return const Center(child: Text('Media not initialized'));
  }

  Widget _buildResultView() {
    final mood = _detectedMood ?? 'Happy';
    final emoji = _moodEmojis[mood] ?? '😊';
    final insight = _getMoodInsight(mood);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.check_circle, color: Colors.green, size: 20),
               const SizedBox(width: 8),
               Text(
                SettingsController().tr("Face scan done"),
                style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            emoji,
            style: const TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 16),
          Text(
            "${SettingsController().tr("You seem to be ")}${SettingsController().tr(mood)}",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          
          // Insight Sections
          _buildInsightSection(SettingsController().tr("Effect on Body"), insight['effect']!),
          const SizedBox(height: 24),
          _buildInsightSection(SettingsController().tr("How to Improve"), insight['improvement']!),
          
          const SizedBox(height: 60),
          _buildActionButton(
            onPressed: _startScan,
            label: SettingsController().tr("Scan again"),
            icon: Icons.refresh,
            outline: true,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            onPressed: () async {
              if (_detectedMood != null) {
                await MoodTrackerController().saveMood(_detectedMood!);
              }
              await GamificationController().unlockBadge('mood_logger');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(SettingsController().tr('Mood saved! Stay healthy. ✨'))),
                );
                Navigator.pop(context);
              }
            },
            label: SettingsController().tr("Save & Finish"),
            icon: Icons.check,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFD81B60)),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    bool outline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: outline 
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF48FB1),
              side: const BorderSide(color: Color(0xFFF48FB1), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF48FB1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
            ),
          ),
    );
  }

  Map<String, String> _getMoodInsight(String mood) {
    switch (mood) {
      case 'Happy':
      case 'Energetic':
        return {
          'effect': 'Positive emotions release serotonin, improving circulation and boosting the baby\'s brain development.',
          'improvement': 'Keep this energy up! Gentle stretching or sharing your joy with loved ones can amplify these benefits.'
        };
      case 'Anxious':
      case 'Irritated':
        return {
          'effect': 'Stress can cause a temporary spike in cortisol levels, which might affect your rest and baby\'s heart rate.',
          'improvement': 'Try deep breathing (4-7-8) for 5 minutes. Listen to calming music or nature sounds.'
        };
      case 'Sad':
      case 'Tired':
        return {
          'effect': 'Low energy can feel draining. Resting allows your body to dedicate nutrients to the baby\'s growth.',
          'improvement': 'A short nap or a warm bath can help. Remember to stay hydrated and take it one step at a time.'
        };
      default:
        return {
          'effect': 'Every emotion is valid during this journey.',
          'improvement': 'Listen to your body. If you feel tired, rest. If you feel joy, embrace it.'
        };
    }
  }
}
