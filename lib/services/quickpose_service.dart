import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class QuickPoseService {
  static const String _sdkKey = '01K4DKC13739EYV3FC1PGAD5P9';
  static const MethodChannel _channel = MethodChannel('quickpose_flutter');
  static bool _isInitialized = false;

  // Initialize QuickPose SDK
  static Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Initialize QuickPose with SDK key via platform channel
      final result = await _channel.invokeMethod('initialize', {
        'sdkKey': _sdkKey,
      });
      
      _isInitialized = result == true;
      debugPrint('✅ QuickPose SDK initialized successfully');
      return _isInitialized;
    } catch (e) {
      debugPrint('❌ Failed to initialize QuickPose SDK: $e');
      return false;
    }
  }

  // Check and request camera permissions
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('❌ Failed to request camera permission: $e');
      return false;
    }
  }

  // Get available cameras
  static Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      debugPrint('❌ Failed to get available cameras: $e');
      return [];
    }
  }

  // Start exercise tracking session
  static Future<bool> startExerciseTracking(String exerciseName) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Configure exercise-specific pose detection
      final exerciseType = _getExerciseType(exerciseName);
      
      final result = await _channel.invokeMethod('startTracking', {
        'exerciseType': exerciseType.name,
        'exerciseName': exerciseName,
      });
      
      debugPrint('✅ Started exercise tracking for: $exerciseName');
      return result == true;
    } catch (e) {
      debugPrint('❌ Failed to start exercise tracking: $e');
      return false;
    }
  }

  // Stop exercise tracking
  static Future<void> stopExerciseTracking() async {
    try {
      await _channel.invokeMethod('stopTracking');
      debugPrint('✅ Stopped exercise tracking');
    } catch (e) {
      debugPrint('❌ Failed to stop exercise tracking: $e');
    }
  }

  // Get exercise results/statistics
  static Future<ExerciseResults?> getExerciseResults() async {
    try {
      final result = await _channel.invokeMethod('getResults');
      if (result != null) {
        return ExerciseResults.fromJson(Map<String, dynamic>.from(result));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get exercise results: $e');
      return null;
    }
  }

  // Listen to real-time updates
  static Stream<Map<String, dynamic>> get exerciseUpdates {
    return const EventChannel('quickpose_flutter/updates')
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
  }

  // Determine exercise type from name
  static ExerciseType _getExerciseType(String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    if (name.contains('push') && name.contains('up')) {
      return ExerciseType.pushUp;
    } else if (name.contains('squat')) {
      return ExerciseType.squat;
    } else if (name.contains('lunge')) {
      return ExerciseType.lunge;
    } else if (name.contains('plank')) {
      return ExerciseType.plank;
    } else if (name.contains('curl') && (name.contains('bicep') || name.contains('arm'))) {
      return ExerciseType.bicepCurl;
    }
    
    return ExerciseType.general;
  }

  // Dispose resources
  static Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
      _isInitialized = false;
      debugPrint('✅ QuickPose service disposed');
    } catch (e) {
      debugPrint('❌ Failed to dispose QuickPose service: $e');
    }
  }
}

// Exercise types supported by QuickPose
enum ExerciseType {
  pushUp,
  squat,
  lunge,
  plank,
  bicepCurl,
  general,
}

// Exercise results data class
class ExerciseResults {
  final int repetitions;
  final double accuracy;
  final Duration duration;
  final List<String> feedback;
  final Map<String, dynamic> analytics;

  ExerciseResults({
    required this.repetitions,
    required this.accuracy,
    required this.duration,
    required this.feedback,
    required this.analytics,
  });

  factory ExerciseResults.fromJson(Map<String, dynamic> json) {
    return ExerciseResults(
      repetitions: json['repetitions'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      duration: Duration(seconds: json['duration'] ?? 0),
      feedback: List<String>.from(json['feedback'] ?? []),
      analytics: json['analytics'] ?? {},
    );
  }
}