import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../models/prescription_exercise.dart';
import '../services/quickpose_service.dart';

class ExerciseTrackingPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseTrackingPage({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseTrackingPage> createState() => _ExerciseTrackingPageState();
}

class _ExerciseTrackingPageState extends State<ExerciseTrackingPage> {
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isTracking = false;
  bool _hasPermission = false;
  int _repetitions = 0;
  double _accuracy = 0.0;
  Duration _exerciseDuration = Duration.zero;
  DateTime? _startTime;
  List<String> _feedback = [];
  Timer? _exerciseTimer;
  StreamSubscription<Map<String, dynamic>>? _exerciseUpdateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    _exerciseUpdateSubscription?.cancel();
    _cameraController?.dispose();
    QuickPoseService.stopExerciseTracking();
    QuickPoseService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final hasPermission = await QuickPoseService.requestCameraPermission();
      if (!hasPermission) {
        setState(() {
          _isInitializing = false;
          _hasPermission = false;
        });
        return;
      }

      // Get available cameras
      final cameras = await QuickPoseService.getAvailableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _hasPermission = false;
        });
        return;
      }

      // Initialize camera controller with front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Initialize QuickPose SDK
      await QuickPoseService.initialize();

      setState(() {
        _isInitializing = false;
        _hasPermission = true;
      });
    } catch (e) {
      debugPrint('❌ Failed to initialize camera: $e');
      setState(() {
        _isInitializing = false;
        _hasPermission = false;
      });
    }
  }

  Future<void> _startExerciseTracking() async {
    try {
      final success = await QuickPoseService.startExerciseTracking(widget.exercise.name);
      if (success) {
        setState(() {
          _isTracking = true;
          _startTime = DateTime.now();
          _repetitions = 0;
          _accuracy = 0.0;
          _feedback.clear();
        });
        
        // Start exercise timer
        _startExerciseTimer();
        
        // Listen to real-time exercise updates
        _exerciseUpdateSubscription = QuickPoseService.exerciseUpdates.listen(
          _handleExerciseUpdate,
          onError: (error) {
            debugPrint('❌ Exercise update error: $error');
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to start exercise tracking: $e');
      _showErrorSnackBar('Failed to start exercise tracking');
    }
  }

  void _handleExerciseUpdate(Map<String, dynamic> update) {
    if (mounted && _isTracking) {
      setState(() {
        _repetitions = update['repetitions'] ?? _repetitions;
        _accuracy = (update['accuracy'] ?? _accuracy).toDouble();
        
        // Add any new feedback
        final newFeedback = update['feedback'];
        if (newFeedback != null && newFeedback is String && !_feedback.contains(newFeedback)) {
          _feedback.add(newFeedback);
        }
      });
    }
  }

  Future<void> _stopExerciseTracking() async {
    try {
      // Cancel subscriptions
      _exerciseUpdateSubscription?.cancel();
      _exerciseTimer?.cancel();
      
      await QuickPoseService.stopExerciseTracking();
      
      // Get final exercise results
      final results = await QuickPoseService.getExerciseResults();
      if (results != null) {
        setState(() {
          _repetitions = results.repetitions;
          _accuracy = results.accuracy;
          _exerciseDuration = results.duration;
          _feedback = results.feedback;
        });
      } else {
        // Use current tracking data if no results available
        setState(() {
          _exerciseDuration = _startTime != null 
              ? DateTime.now().difference(_startTime!)
              : _exerciseDuration;
        });
      }

      setState(() {
        _isTracking = false;
      });

      // Show results dialog
      _showExerciseResults();
    } catch (e) {
      debugPrint('❌ Failed to stop exercise tracking: $e');
      _showErrorSnackBar('Failed to stop exercise tracking');
    }
  }

  void _startExerciseTimer() {
    _exerciseTimer?.cancel();
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking && _startTime != null && mounted) {
        setState(() {
          _exerciseDuration = DateTime.now().difference(_startTime!);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showExerciseResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exercise: ${widget.exercise.name}'),
            const SizedBox(height: 8),
            Text('Repetitions: $_repetitions'),
            const SizedBox(height: 8),
            Text('Accuracy: ${(_accuracy * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Duration: ${_exerciseDuration.inMinutes}:${(_exerciseDuration.inSeconds % 60).toString().padLeft(2, '0')}'),
            if (_feedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ..._feedback.map((feedback) => Text('• $feedback')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close tracking page
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _startExerciseTracking(); // Start new session
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: widget.exercise.primaryMuscleColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isTracking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${_exerciseDuration.inMinutes}:${(_exerciseDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera and pose detection...'),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera permission required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please grant camera access to track your exercise',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        if (_cameraController != null && _cameraController!.value.isInitialized)
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

        // Exercise information overlay
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isTracking) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Reps: $_repetitions',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Accuracy: ${(_accuracy * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // Exercise instructions
        if (!_isTracking)
          Positioned(
            bottom: 200,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exercise Instructions:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.exercise.instructions.isNotEmpty)
                    ...widget.exercise.instructions.take(3).map(
                      (instruction) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $instruction'),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Control buttons
        Positioned(
          bottom: 32,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isTracking) ...[
                ElevatedButton.icon(
                  onPressed: _startExerciseTracking,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Exercise'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.exercise.primaryMuscleColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _stopExerciseTracking,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Exercise'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}