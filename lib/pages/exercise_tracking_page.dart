import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/prescription_exercise.dart';
import '../services/quickpose_service.dart';
import '../widgets/pose_overlay_painter.dart';
import '../widgets/corner_skeleton_painter.dart';

class ExerciseTrackingPage extends StatefulWidget {
  final Exercise exercise;

  const ExerciseTrackingPage({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  State<ExerciseTrackingPage> createState() => _ExerciseTrackingPageState();
}

class _ExerciseTrackingPageState extends State<ExerciseTrackingPage> {
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;
  bool _isInitializing = false;
  bool _isTracking = false;
  bool _hasPerson = false;
  bool _showSkeleton = true;
  bool _skeletonInCorner = false; // New option for bottom-right positioning
  
  int _repetitions = 0;
  double _accuracy = 0.0;
  Duration _exerciseDuration = Duration.zero;
  DateTime? _startTime;
  Timer? _exerciseTimer;
  
  StreamSubscription? _exerciseUpdateSubscription;
  StreamSubscription? _poseStreamSubscription;
  List<String> _feedback = [];
  List<PoseKeypoint> _currentKeypoints = [];
  
  final QuickPoseService _quickPoseService = QuickPoseService.instance;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeQuickPose();
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    _exerciseUpdateSubscription?.cancel();
    _poseStreamSubscription?.cancel();
    _cameraController?.dispose();
    // Don't dispose the singleton service, just stop current exercise if tracking
    if (_isTracking) {
      _quickPoseService.stopExercise();
    }
    super.dispose();
  }

  Future<void> _initializeQuickPose() async {
    try {
      // Always initialize the service to ensure it's ready
      await _quickPoseService.initialize();
      
      // Listen to pose stream for real-time skeleton data
      _poseStreamSubscription = _quickPoseService.poseStream.listen((poseData) {
        if (mounted) {
          setState(() {
            _hasPerson = poseData['hasPerson'] ?? false;
            _repetitions = poseData['reps'] ?? 0;
            _exerciseDuration = Duration(seconds: poseData['duration'] ?? 0);
            
            // Convert landmarks to keypoints for skeleton visualization
            final landmarks = poseData['landmarks'] as Map<String, Map<String, double>>? ?? {};
            _currentKeypoints = _convertLandmarksToKeypoints(landmarks);
          });
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to initialize pose detection: ${e.toString()}');
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        _showErrorSnackBar('Camera permission denied');
        return;
      }

      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        _showErrorSnackBar('No cameras available');
        return;
      }

      _currentCameraIndex = _availableCameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      if (_currentCameraIndex == -1) {
        _currentCameraIndex = 0;
      }

      _cameraController = CameraController(
        _availableCameras[_currentCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Start image stream for pose detection
      if (mounted && _cameraController!.value.isInitialized) {
        _cameraController!.startImageStream((CameraImage image) {
          _quickPoseService.processImage(image);
        });
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to initialize camera: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  List<PoseKeypoint> _convertLandmarksToKeypoints(Map<String, Map<String, double>> landmarks) {
    final keypoints = <PoseKeypoint>[];
    
    for (final entry in landmarks.entries) {
      final landmarkName = entry.key;
      final landmark = entry.value;
      
      final keypointType = _getKeypointType(landmarkName);
      if (keypointType != KeypointType.unknown) {
        keypoints.add(PoseKeypoint(
          type: keypointType,
          x: landmark['x'] ?? 0.0,
          y: landmark['y'] ?? 0.0,
          confidence: landmark['visibility'] ?? 0.0,
        ));
      }
    }
    
    return keypoints;
  }

  KeypointType _getKeypointType(String landmarkName) {
    switch (landmarkName) {
      case 'nose':
        return KeypointType.nose;
      case 'left_eye':
        return KeypointType.leftEye;
      case 'right_eye':
        return KeypointType.rightEye;
      case 'left_ear':
        return KeypointType.leftEar;
      case 'right_ear':
        return KeypointType.rightEar;
      case 'left_shoulder':
        return KeypointType.leftShoulder;
      case 'right_shoulder':
        return KeypointType.rightShoulder;
      case 'left_elbow':
        return KeypointType.leftElbow;
      case 'right_elbow':
        return KeypointType.rightElbow;
      case 'left_wrist':
        return KeypointType.leftWrist;
      case 'right_wrist':
        return KeypointType.rightWrist;
      case 'left_hip':
        return KeypointType.leftHip;
      case 'right_hip':
        return KeypointType.rightHip;
      case 'left_knee':
        return KeypointType.leftKnee;
      case 'right_knee':
        return KeypointType.rightKnee;
      case 'left_ankle':
        return KeypointType.leftAnkle;
      case 'right_ankle':
        return KeypointType.rightAnkle;
      default:
        return KeypointType.unknown;
    }
  }

  Future<void> _startTracking() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showErrorSnackBar('Camera not ready');
      return;
    }

    try {
      setState(() {
        _isTracking = true;
        _startTime = DateTime.now();
        _repetitions = 0;
        _exerciseDuration = Duration.zero;
      });

      // Start exercise tracking in QuickPose service
      _quickPoseService.startExercise(widget.exercise.name);
      
      _showErrorSnackBar('Exercise tracking started! 🏃‍♂️');
    } catch (e) {
      _showErrorSnackBar('Failed to start tracking: ${e.toString()}');
      setState(() {
        _isTracking = false;
      });
    }
  }

  Future<void> _stopTracking() async {
    try {
      setState(() {
        _isTracking = false;
      });

      // Stop exercise tracking
      _quickPoseService.stopExercise();
      
      _showExerciseResults();
    } catch (e) {
      _showErrorSnackBar('Failed to stop tracking: ${e.toString()}');
    }
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
            Text('Duration: ${_exerciseDuration.inMinutes}:${(_exerciseDuration.inSeconds % 60).toString().padLeft(2, '0')}'),
            const SizedBox(height: 8),
            Text('Person detected: ${_hasPerson ? "Yes" : "No"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTracking();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _cameraController!.value.aspectRatio,
      child: Stack(
        children: [
          // Camera preview
          CameraPreview(_cameraController!),
          
          // Full overlay skeleton (when not in corner mode)
          if (_showSkeleton && !_skeletonInCorner && _currentKeypoints.isNotEmpty)
            CustomPaint(
              painter: PoseOverlayPainter(
                keypoints: _currentKeypoints,
                connections: PoseConnections.humanSkeleton,
                cameraSize: _cameraController!.value.previewSize ?? const Size(1, 1),
              ),
              size: Size.infinite,
            ),
          
          // Corner skeleton (when in corner mode)
          if (_showSkeleton && _skeletonInCorner && _currentKeypoints.isNotEmpty)
            CustomPaint(
              painter: CornerSkeletonPainter(
                keypoints: _currentKeypoints,
                connections: PoseConnections.humanSkeleton,
                cameraSize: _cameraController!.value.previewSize ?? const Size(1, 1),
              ),
              size: Size.infinite,
            ),
          
          // Person detection indicator
          if (!_hasPerson && _isTracking)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No person detected\nStep into camera view',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          
          // Real-time stats overlay
          if (_isTracking)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _hasPerson ? Icons.person : Icons.person_off,
                          color: _hasPerson ? Colors.lime : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _hasPerson ? 'Tracking' : 'Searching...',
                          style: TextStyle(
                            color: _hasPerson ? Colors.lime : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentKeypoints.length}/17 points',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    if (_hasPerson) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Avg: ${(_currentKeypoints.isNotEmpty ? (_currentKeypoints.map((kp) => kp.confidence).reduce((a, b) => a + b) / _currentKeypoints.length * 100).toStringAsFixed(0) : "0")}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: widget.exercise.primaryMuscleColor,
        actions: [
          // Skeleton toggle button
          if (_cameraController != null && _cameraController!.value.isInitialized)
            IconButton(
              icon: Icon(
                _showSkeleton ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _showSkeleton = !_showSkeleton;
                });
              },
              tooltip: _showSkeleton ? 'Hide Skeleton' : 'Show Skeleton',
            ),
          
          // Skeleton position toggle button
          if (_cameraController != null && _cameraController!.value.isInitialized && _showSkeleton)
            IconButton(
              icon: Icon(
                _skeletonInCorner ? Icons.picture_in_picture : Icons.fullscreen,
              ),
              onPressed: () {
                setState(() {
                  _skeletonInCorner = !_skeletonInCorner;
                });
              },
              tooltip: _skeletonInCorner ? 'Full Screen Skeleton' : 'Corner Skeleton',
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: _buildCameraPreview(),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                top: BorderSide(color: Colors.grey[700]!),
              ),
            ),
            child: Column(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Reps: $_repetitions',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Time: ${_exerciseDuration.inMinutes}:${(_exerciseDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  if (_showSkeleton && _hasPerson) ...[
                    const SizedBox(height: 8),
                    Text(
                      '✓ Real-time skeleton tracking active',
                      style: TextStyle(
                        color: Colors.lime,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
                
                const SizedBox(height: 16),
                
                if (!_isTracking) ...[
                  const Text(
                    'Get ready to start your exercise!\nMake sure you are fully visible in the camera.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (widget.exercise.instructions.isNotEmpty)
                    ...widget.exercise.instructions.take(3).map(
                      (instruction) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $instruction',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!_isTracking) ...[
                      ElevatedButton.icon(
                        onPressed: _startTracking,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Exercise'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.exercise.primaryMuscleColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: _stopTracking,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Exercise'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
