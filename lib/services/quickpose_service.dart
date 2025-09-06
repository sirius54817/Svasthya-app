import 'dart:async';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'mlkit_pose_service.dart';

class QuickPoseService {
  static QuickPoseService? _instance;
  static QuickPoseService get instance => _instance ??= QuickPoseService._();
  
  QuickPoseService._();

  final MLKitPoseService _mlkitService = MLKitPoseService.instance;
  
  // Stream controllers for pose data
  final StreamController<Map<String, dynamic>> _poseStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get poseStream => _poseStreamController.stream;

  // Exercise tracking state
  bool _isTracking = false;
  String _currentExercise = '';
  int _reps = 0;
  Duration _duration = Duration.zero;
  Timer? _durationTimer;
  StreamSubscription<List<Pose>>? _poseSubscription;

  bool get isTracking => _isTracking;
  String get currentExercise => _currentExercise;
  int get reps => _reps;
  Duration get duration => _duration;

  Future<void> initialize() async {
    // Always initialize ML Kit service - it's safe to call multiple times
    await _mlkitService.initialize();
    
    // Only set up subscription if not already listening
    if (_poseSubscription == null) {
      _poseSubscription = _mlkitService.poseStream.listen((poses) {
        _processPoses(poses);
      });
    }
  }

  void _processPoses(List<Pose> poses) {
    if (!_isTracking) return;

    // Convert poses to landmarks format expected by UI
    final landmarks = <String, Map<String, double>>{};
    
    if (poses.isNotEmpty) {
      final pose = poses.first;
      
      for (final landmark in pose.landmarks.values) {
        String landmarkName = _getLandmarkName(landmark.type);
        landmarks[landmarkName] = {
          'x': landmark.x,
          'y': landmark.y,
          'z': landmark.z ?? 0.0,
          'visibility': landmark.likelihood,
        };
      }

      // Basic rep counting logic
      if (_canCountRep(landmarks)) {
        _reps++;
      }
    }

    final poseData = {
      'landmarks': landmarks,
      'reps': _reps,
      'duration': _duration.inSeconds,
      'exercise': _currentExercise,
      'hasPerson': poses.isNotEmpty,
    };

    _poseStreamController.add(poseData);
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
    final leftShoulder = landmarks['left_shoulder'];
    final rightShoulder = landmarks['right_shoulder'];
    
    if (leftShoulder == null || rightShoulder == null) return false;
    
    // Check if both shoulders are visible with high confidence
    final leftVisibility = leftShoulder['visibility'] ?? 0.0;
    final rightVisibility = rightShoulder['visibility'] ?? 0.0;
    
    return leftVisibility > 0.7 && rightVisibility > 0.7;
  }

  Future<void> processImage(CameraImage image) async {
    await _mlkitService.processImage(image);
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

    // Start exercise tracking in ML Kit service
    _mlkitService.startExercise(exerciseName);
  }

  void stopExercise() {
    _isTracking = false;
    _durationTimer?.cancel();
    _currentExercise = '';
    
    // Stop exercise tracking in ML Kit service
    _mlkitService.stopExercise();
  }

  void dispose() {
    // Only cancel timers and subscriptions, don't dispose the singleton
    _durationTimer?.cancel();
    _durationTimer = null;
    _poseSubscription?.cancel();
    _poseSubscription = null;
    
    // Reset tracking state
    _isTracking = false;
    _currentExercise = '';
    _reps = 0;
    _duration = Duration.zero;
    
    // Don't close the stream controller as it's used by multiple pages
    // and don't dispose ML Kit service as it's also a singleton
  }
}