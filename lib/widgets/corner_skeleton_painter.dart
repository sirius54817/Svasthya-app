import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'pose_overlay_painter.dart';

class CornerSkeletonPainter extends CustomPainter {
  final List<PoseKeypoint> keypoints;
  final List<PoseConnection> connections;
  final Size cameraSize;
  
  CornerSkeletonPainter({
    required this.keypoints,
    required this.connections,
    required this.cameraSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.isEmpty) return;

    // Define corner skeleton area (bottom-right)
    const double skeletonWidth = 150.0;
    const double skeletonHeight = 200.0;
    const double margin = 16.0;
    
    final skeletonRect = Rect.fromLTWH(
      size.width - skeletonWidth - margin,
      size.height - skeletonHeight - margin,
      skeletonWidth,
      skeletonHeight,
    );

    // Draw background for skeleton area
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(skeletonRect, const Radius.circular(8.0)),
      backgroundPaint,
    );

    // Normalize and scale keypoints to fit in corner area
    final normalizedKeypoints = _normalizeKeypointsToCorner(keypoints, skeletonRect);

    // Paint for keypoints (joints)
    final keypointPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    // Paint for connections (skeleton lines)
    final connectionPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Paint for high-confidence keypoints
    final highConfidencePaint = Paint()
      ..color = Colors.lime
      ..style = PaintingStyle.fill;

    // Draw connections (skeleton lines) first
    for (final connection in connections) {
      final startKeypoint = normalizedKeypoints.firstWhere(
        (kp) => kp.type == connection.startJoint,
        orElse: () => PoseKeypoint.empty(),
      );
      final endKeypoint = normalizedKeypoints.firstWhere(
        (kp) => kp.type == connection.endJoint,
        orElse: () => PoseKeypoint.empty(),
      );

      if (startKeypoint.isValid && endKeypoint.isValid) {
        final startPoint = Offset(startKeypoint.x, startKeypoint.y);
        final endPoint = Offset(endKeypoint.x, endKeypoint.y);

        // Use different colors for different body parts
        connectionPaint.color = _getConnectionColor(connection.bodyPart);
        canvas.drawLine(startPoint, endPoint, connectionPaint);
      }
    }

    // Draw keypoints (joints) on top
    for (final keypoint in normalizedKeypoints) {
      if (keypoint.isValid) {
        final point = Offset(keypoint.x, keypoint.y);

        // Use different paint based on confidence
        final paint = keypoint.confidence > 0.7 ? highConfidencePaint : keypointPaint;
        canvas.drawCircle(point, 4.0, paint);

        // Draw a smaller inner circle for better visibility
        final innerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 2.0, innerPaint);
      }
    }

    // Draw title
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Pose',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        skeletonRect.left + (skeletonRect.width - textPainter.width) / 2,
        skeletonRect.top + 4,
      ),
    );
  }

  List<PoseKeypoint> _normalizeKeypointsToCorner(List<PoseKeypoint> originalKeypoints, Rect area) {
    if (originalKeypoints.isEmpty) return [];

    // Find bounding box of all valid keypoints
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final keypoint in originalKeypoints) {
      if (keypoint.isValid) {
        minX = math.min(minX, keypoint.x);
        maxX = math.max(maxX, keypoint.x);
        minY = math.min(minY, keypoint.y);
        maxY = math.max(maxY, keypoint.y);
      }
    }

    if (minX == double.infinity) return [];

    // Calculate scale and offset to fit in corner area with padding
    const padding = 16.0;
    final sourceWidth = maxX - minX;
    final sourceHeight = maxY - minY;
    final targetWidth = area.width - (padding * 2);
    final targetHeight = area.height - (padding * 2) - 20; // Reserve space for title

    final scaleX = sourceWidth > 0 ? targetWidth / sourceWidth : 1.0;
    final scaleY = sourceHeight > 0 ? targetHeight / sourceHeight : 1.0;
    final scale = math.min(scaleX, scaleY);

    // Center the scaled skeleton in the area
    final scaledWidth = sourceWidth * scale;
    final scaledHeight = sourceHeight * scale;
    final offsetX = area.left + padding + (targetWidth - scaledWidth) / 2;
    final offsetY = area.top + 20 + padding + (targetHeight - scaledHeight) / 2; // Account for title

    final normalizedKeypoints = <PoseKeypoint>[];
    for (final keypoint in originalKeypoints) {
      if (keypoint.isValid) {
        final normalizedX = offsetX + (keypoint.x - minX) * scale;
        final normalizedY = offsetY + (keypoint.y - minY) * scale;
        
        normalizedKeypoints.add(PoseKeypoint(
          type: keypoint.type,
          x: normalizedX,
          y: normalizedY,
          confidence: keypoint.confidence,
        ));
      }
    }

    return normalizedKeypoints;
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

  @override
  bool shouldRepaint(covariant CornerSkeletonPainter oldDelegate) {
    return keypoints != oldDelegate.keypoints;
  }
}