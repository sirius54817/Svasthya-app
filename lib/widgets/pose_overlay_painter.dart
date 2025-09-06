import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class PoseOverlayPainter extends CustomPainter {
  final List<PoseKeypoint> keypoints;
  final List<PoseConnection> connections;
  final Size cameraSize;
  
  PoseOverlayPainter({
    required this.keypoints,
    required this.connections,
    required this.cameraSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.isEmpty) return;

    // Calculate proper coordinate transformation
    // Camera preview coordinates need to be mapped to widget coordinates
    // Account for aspect ratio and scaling differences
    final double scaleX, scaleY;
    final double offsetX, offsetY;
    
    // Calculate scaling with proper aspect ratio handling
    final cameraAspectRatio = cameraSize.width / cameraSize.height;
    final widgetAspectRatio = size.width / size.height;
    
    if (widgetAspectRatio > cameraAspectRatio) {
      // Widget is wider than camera - scale by height and center horizontally
      scaleY = size.height / cameraSize.height;
      scaleX = scaleY;
      offsetX = (size.width - (cameraSize.width * scaleX)) / 2;
      offsetY = 0;
    } else {
      // Widget is taller than camera - scale by width and center vertically
      scaleX = size.width / cameraSize.width;
      scaleY = scaleX;
      offsetX = 0;
      offsetY = (size.height - (cameraSize.height * scaleY)) / 2;
    }

    // Paint for keypoints (joints)
    final keypointPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    // Paint for connections (skeleton lines)
    final connectionPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Paint for high-confidence keypoints
    final highConfidencePaint = Paint()
      ..color = Colors.lime
      ..style = PaintingStyle.fill;

    // Draw connections (skeleton lines) first
    for (final connection in connections) {
      final startKeypoint = keypoints.firstWhere(
        (kp) => kp.type == connection.startJoint,
        orElse: () => PoseKeypoint.empty(),
      );
      final endKeypoint = keypoints.firstWhere(
        (kp) => kp.type == connection.endJoint,
        orElse: () => PoseKeypoint.empty(),
      );

      if (startKeypoint.isValid && endKeypoint.isValid) {
        final startPoint = Offset(
          (startKeypoint.x * scaleX) + offsetX,
          (startKeypoint.y * scaleY) + offsetY,
        );
        final endPoint = Offset(
          (endKeypoint.x * scaleX) + offsetX,
          (endKeypoint.y * scaleY) + offsetY,
        );

        // Use different colors for different body parts
        connectionPaint.color = _getConnectionColor(connection.bodyPart);
        canvas.drawLine(startPoint, endPoint, connectionPaint);
      }
    }

    // Draw keypoints (joints) on top
    for (final keypoint in keypoints) {
      if (keypoint.isValid) {
        final point = Offset(
          (keypoint.x * scaleX) + offsetX,
          (keypoint.y * scaleY) + offsetY,
        );

        // Use different paint based on confidence
        final paint = keypoint.confidence > 0.7 ? highConfidencePaint : keypointPaint;
        canvas.drawCircle(point, 8.0, paint);

        // Draw a smaller inner circle for better visibility
        final innerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 3.0, innerPaint);
      }
    }

    // Draw exercise-specific indicators
    _drawExerciseIndicators(canvas, size, scaleX, scaleY, offsetX, offsetY);
  }

  Color _getConnectionColor(BodyPart bodyPart) {
    switch (bodyPart) {
      case BodyPart.head:
        return Colors.yellow;
      case BodyPart.torso:
        return Colors.cyan;
      case BodyPart.leftArm:
        return Colors.green;
      case BodyPart.rightArm:
        return Colors.blue;
      case BodyPart.leftLeg:
        return Colors.orange;
      case BodyPart.rightLeg:
        return Colors.purple;
      default:
        return Colors.cyan;
    }
  }

  void _drawExerciseIndicators(Canvas canvas, Size size, double scaleX, double scaleY, double offsetX, double offsetY) {
    // Draw form feedback indicators
    final feedbackPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Example: Draw alignment guides for squats
    final leftKnee = keypoints.firstWhere(
      (kp) => kp.type == KeypointType.leftKnee,
      orElse: () => PoseKeypoint.empty(),
    );
    final rightKnee = keypoints.firstWhere(
      (kp) => kp.type == KeypointType.rightKnee,
      orElse: () => PoseKeypoint.empty(),
    );

    if (leftKnee.isValid && rightKnee.isValid) {
      // Draw knee alignment guide
      final leftKneePoint = Offset(
        (leftKnee.x * scaleX) + offsetX, 
        (leftKnee.y * scaleY) + offsetY
      );
      final rightKneePoint = Offset(
        (rightKnee.x * scaleX) + offsetX, 
        (rightKnee.y * scaleY) + offsetY
      );
      
      canvas.drawLine(leftKneePoint, rightKneePoint, feedbackPaint);
      
      // Draw center line for symmetry reference
      final centerX = (leftKneePoint.dx + rightKneePoint.dx) / 2;
      final topY = math.max(0.0, leftKneePoint.dy - 100);
      final bottomY = math.min(size.height, leftKneePoint.dy + 100);
      
      final centerLinePaint = Paint()
        ..color = Colors.yellow.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
        
      canvas.drawLine(
        Offset(centerX, topY),
        Offset(centerX, bottomY),
        centerLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PoseOverlayPainter oldDelegate) {
    return keypoints != oldDelegate.keypoints;
  }
}

// Pose keypoint data structure
class PoseKeypoint {
  final KeypointType type;
  final double x;
  final double y;
  final double confidence;

  PoseKeypoint({
    required this.type,
    required this.x,
    required this.y,
    required this.confidence,
  });

  bool get isValid => confidence > 0.3; // Minimum confidence threshold

  static PoseKeypoint empty() => PoseKeypoint(
    type: KeypointType.unknown,
    x: 0,
    y: 0,
    confidence: 0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PoseKeypoint &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          x == other.x &&
          y == other.y &&
          confidence == other.confidence;

  @override
  int get hashCode => type.hashCode ^ x.hashCode ^ y.hashCode ^ confidence.hashCode;
}

// Pose connection between keypoints
class PoseConnection {
  final KeypointType startJoint;
  final KeypointType endJoint;
  final BodyPart bodyPart;

  PoseConnection({
    required this.startJoint,
    required this.endJoint,
    required this.bodyPart,
  });
}

// Keypoint types based on common pose detection models
enum KeypointType {
  // Head
  nose,
  leftEye,
  rightEye,
  leftEar,
  rightEar,
  
  // Torso
  leftShoulder,
  rightShoulder,
  leftHip,
  rightHip,
  
  // Arms
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  
  // Legs
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  
  unknown,
}

// Body parts for color coding
enum BodyPart {
  head,
  torso,
  leftArm,
  rightArm,
  leftLeg,
  rightLeg,
}

// Predefined pose connections for human skeleton
class PoseConnections {
  static final List<PoseConnection> humanSkeleton = [
    // Head connections
    PoseConnection(startJoint: KeypointType.nose, endJoint: KeypointType.leftEye, bodyPart: BodyPart.head),
    PoseConnection(startJoint: KeypointType.nose, endJoint: KeypointType.rightEye, bodyPart: BodyPart.head),
    PoseConnection(startJoint: KeypointType.leftEye, endJoint: KeypointType.leftEar, bodyPart: BodyPart.head),
    PoseConnection(startJoint: KeypointType.rightEye, endJoint: KeypointType.rightEar, bodyPart: BodyPart.head),
    
    // Torso connections
    PoseConnection(startJoint: KeypointType.leftShoulder, endJoint: KeypointType.rightShoulder, bodyPart: BodyPart.torso),
    PoseConnection(startJoint: KeypointType.leftShoulder, endJoint: KeypointType.leftHip, bodyPart: BodyPart.torso),
    PoseConnection(startJoint: KeypointType.rightShoulder, endJoint: KeypointType.rightHip, bodyPart: BodyPart.torso),
    PoseConnection(startJoint: KeypointType.leftHip, endJoint: KeypointType.rightHip, bodyPart: BodyPart.torso),
    
    // Left arm connections
    PoseConnection(startJoint: KeypointType.leftShoulder, endJoint: KeypointType.leftElbow, bodyPart: BodyPart.leftArm),
    PoseConnection(startJoint: KeypointType.leftElbow, endJoint: KeypointType.leftWrist, bodyPart: BodyPart.leftArm),
    
    // Right arm connections
    PoseConnection(startJoint: KeypointType.rightShoulder, endJoint: KeypointType.rightElbow, bodyPart: BodyPart.rightArm),
    PoseConnection(startJoint: KeypointType.rightElbow, endJoint: KeypointType.rightWrist, bodyPart: BodyPart.rightArm),
    
    // Left leg connections
    PoseConnection(startJoint: KeypointType.leftHip, endJoint: KeypointType.leftKnee, bodyPart: BodyPart.leftLeg),
    PoseConnection(startJoint: KeypointType.leftKnee, endJoint: KeypointType.leftAnkle, bodyPart: BodyPart.leftLeg),
    
    // Right leg connections
    PoseConnection(startJoint: KeypointType.rightHip, endJoint: KeypointType.rightKnee, bodyPart: BodyPart.rightLeg),
    PoseConnection(startJoint: KeypointType.rightKnee, endJoint: KeypointType.rightAnkle, bodyPart: BodyPart.rightLeg),
  ];
}