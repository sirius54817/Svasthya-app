import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class MLKitPoseService {
  static MLKitPoseService? _instance;
  static MLKitPoseService get instance => _instance ??= MLKitPoseService._();
  
  MLKitPoseService._();

  late PoseDetector _poseDetector;
  bool _isInitialized = false;
  
  // Stream controllers for pose data
  final StreamController<List<Pose>> _poseStreamController = StreamController<List<Pose>>.broadcast();
  Stream<List<Pose>> get poseStream => _poseStreamController.stream;

  // Exercise tracking state
  bool _isTracking = false;
  String _currentExercise = '';
  int _reps = 0;
  Duration _duration = Duration.zero;
  Timer? _durationTimer;

  bool get isTracking => _isTracking;
  String get currentExercise => _currentExercise;
  int get reps => _reps;
  Duration get duration => _duration;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure pose detection options
      final options = PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      );

      _poseDetector = PoseDetector(options: options);
      _isInitialized = true;
      print('MLKitPoseService initialized successfully');
    } catch (e) {
      print('Error initializing MLKitPoseService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> dispose() async {
    // Only dispose if explicitly called - this is a singleton service
    // Don't dispose automatically from page dispose methods
    if (!_isInitialized) return;

    try {
      await _poseDetector.close();
      await _poseStreamController.close();
      _durationTimer?.cancel();
      _isInitialized = false;
      print('MLKitPoseService disposed');
    } catch (e) {
      print('Error disposing MLKitPoseService: $e');
    }
  }

  Future<void> processImage(CameraImage image) async {
    if (!_isInitialized) return;

    try {
      // Convert CameraImage to InputImage for ML Kit
      final inputImage = _convertCameraImageToInputImage(image);
      
      // Detect poses
      final poses = await _poseDetector.processImage(inputImage);
      
      // Emit poses to stream
      _poseStreamController.add(poses);

      // Process poses for exercise tracking if active
      if (_isTracking && poses.isNotEmpty) {
        _processExercisePoses(poses);
      }
    } catch (e) {
      print('Error processing pose detection: $e');
      // Emit empty list on error
      _poseStreamController.add([]);
    }
  }

  InputImage _convertCameraImageToInputImage(CameraImage image) {
    // Convert camera image to bytes
    final allBytes = <int>[];
    for (final plane in image.planes) {
      allBytes.addAll(plane.bytes);
    }
    final bytes = Uint8List.fromList(allBytes);

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final InputImageRotation imageRotation = InputImageRotation.rotation0deg;

    final InputImageFormat inputImageFormat = InputImageFormat.nv21;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  void startExercise(String exerciseName) {
    _currentExercise = exerciseName;
    _reps = 0;
    _duration = Duration.zero;
    _isTracking = true;
    
    // Start duration timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = Duration(seconds: _duration.inSeconds + 1);
    });
  }

  void stopExercise() {
    _isTracking = false;
    _durationTimer?.cancel();
    _currentExercise = '';
  }

  void _processExercisePoses(List<Pose> poses) {
    if (poses.isEmpty) return;

    final pose = poses.first; // Use the first detected pose
    
    // Convert pose landmarks to the format expected by the UI
    final landmarks = <String, Map<String, double>>{};
    
    for (final landmark in pose.landmarks.values) {
      String landmarkName = _getLandmarkName(landmark.type);
      landmarks[landmarkName] = {
        'x': landmark.x,
        'y': landmark.y,
        'z': landmark.z ?? 0.0,
        'visibility': landmark.likelihood,
      };
    }

    // Basic rep counting logic based on shoulder movement
    // This is a simplified version - you can enhance this for specific exercises
    if (_canCountRep(landmarks)) {
      _reps++;
    }
  }

  String _getLandmarkName(PoseLandmarkType type) {
    switch (type) {
      case PoseLandmarkType.nose:
        return 'nose';
      case PoseLandmarkType.leftEyeInner:
        return 'left_eye_inner';
      case PoseLandmarkType.leftEye:
        return 'left_eye';
      case PoseLandmarkType.leftEyeOuter:
        return 'left_eye_outer';
      case PoseLandmarkType.rightEyeInner:
        return 'right_eye_inner';
      case PoseLandmarkType.rightEye:
        return 'right_eye';
      case PoseLandmarkType.rightEyeOuter:
        return 'right_eye_outer';
      case PoseLandmarkType.leftEar:
        return 'left_ear';
      case PoseLandmarkType.rightEar:
        return 'right_ear';
      case PoseLandmarkType.leftMouth:
        return 'mouth_left';
      case PoseLandmarkType.rightMouth:
        return 'mouth_right';
      case PoseLandmarkType.leftShoulder:
        return 'left_shoulder';
      case PoseLandmarkType.rightShoulder:
        return 'right_shoulder';
      case PoseLandmarkType.leftElbow:
        return 'left_elbow';
      case PoseLandmarkType.rightElbow:
        return 'right_elbow';
      case PoseLandmarkType.leftWrist:
        return 'left_wrist';
      case PoseLandmarkType.rightWrist:
        return 'right_wrist';
      case PoseLandmarkType.leftPinky:
        return 'left_pinky';
      case PoseLandmarkType.rightPinky:
        return 'right_pinky';
      case PoseLandmarkType.leftIndex:
        return 'left_index';
      case PoseLandmarkType.rightIndex:
        return 'right_index';
      case PoseLandmarkType.leftThumb:
        return 'left_thumb';
      case PoseLandmarkType.rightThumb:
        return 'right_thumb';
      case PoseLandmarkType.leftHip:
        return 'left_hip';
      case PoseLandmarkType.rightHip:
        return 'right_hip';
      case PoseLandmarkType.leftKnee:
        return 'left_knee';
      case PoseLandmarkType.rightKnee:
        return 'right_knee';
      case PoseLandmarkType.leftAnkle:
        return 'left_ankle';
      case PoseLandmarkType.rightAnkle:
        return 'right_ankle';
      case PoseLandmarkType.leftHeel:
        return 'left_heel';
      case PoseLandmarkType.rightHeel:
        return 'right_heel';
      case PoseLandmarkType.leftFootIndex:
        return 'left_foot_index';
      case PoseLandmarkType.rightFootIndex:
        return 'right_foot_index';
      default:
        return 'unknown';
    }
  }

  bool _canCountRep(Map<String, Map<String, double>> landmarks) {
    // Simple rep counting logic - you can enhance this for specific exercises
    // For now, we'll use a basic shoulder movement detection
    
    final leftShoulder = landmarks['left_shoulder'];
    final rightShoulder = landmarks['right_shoulder'];
    
    if (leftShoulder == null || rightShoulder == null) return false;
    
    // Check if both shoulders are visible with high confidence
    final leftVisibility = leftShoulder['visibility'] ?? 0.0;
    final rightVisibility = rightShoulder['visibility'] ?? 0.0;
    
    return leftVisibility > 0.7 && rightVisibility > 0.7;
  }

  // Utility method to convert poses to the format expected by PoseOverlayPainter
  List<Map<String, dynamic>> convertPosesToLandmarks(List<Pose> poses) {
    if (poses.isEmpty) return [];

    final pose = poses.first;
    final landmarks = <Map<String, dynamic>>[];

    for (final landmark in pose.landmarks.values) {
      landmarks.add({
        'type': _getLandmarkName(landmark.type),
        'x': landmark.x,
        'y': landmark.y,
        'z': landmark.z ?? 0.0,
        'visibility': landmark.likelihood,
      });
    }

    return landmarks;
  }
}