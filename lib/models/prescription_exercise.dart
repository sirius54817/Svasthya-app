import 'package:flutter/material.dart';

/// Model for prescription exercises from the database
class PrescriptionExercise {
  final String id;
  final String? prescriptionId;
  final String? exerciseId;
  final int sets;
  final int? reps;
  final String? duration;
  final String frequency;
  final String? specialInstructions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PrescriptionExercise({
    required this.id,
    this.prescriptionId,
    this.exerciseId,
    required this.sets,
    this.reps,
    this.duration,
    required this.frequency,
    this.specialInstructions,
    this.createdAt,
    this.updatedAt,
  });

  factory PrescriptionExercise.fromJson(Map<String, dynamic> json) {
    return PrescriptionExercise(
      id: json['id'] ?? '',
      prescriptionId: json['prescription_id'],
      exerciseId: json['exercise_id'],
      sets: json['sets'] ?? 1,
      reps: json['reps'],
      duration: json['duration'],
      frequency: json['frequency'] ?? '',
      specialInstructions: json['special_instructions'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_id': prescriptionId,
      'exercise_id': exerciseId,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'frequency': frequency,
      'special_instructions': specialInstructions,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get setsAndRepsInfo {
    if (reps != null) {
      return '$sets sets × $reps reps';
    } else if (duration != null) {
      return '$sets sets × $duration';
    } else {
      return '$sets sets';
    }
  }

  Color get frequencyColor {
    final lowerFreq = frequency.toLowerCase();
    if (lowerFreq.contains('daily') || lowerFreq.contains('once')) {
      return Colors.green;
    } else if (lowerFreq.contains('twice') || lowerFreq.contains('2')) {
      return Colors.amber;
    } else {
      return Colors.blue;
    }
  }

  bool get hasSpecialInstructions => 
      specialInstructions != null && specialInstructions!.isNotEmpty;

  String get workoutTypeDescription {
    if (duration != null && duration!.isNotEmpty) {
      return 'Time-based exercise';
    } else if (reps != null && reps! > 0) {
      return 'Repetition-based exercise';
    } else {
      return 'Set-based exercise';
    }
  }
}

/// Model for exercises from the ExerciseDB API
class Exercise {
  final String exerciseId;
  final String name;
  final String gifUrl;
  final List<String> targetMuscles;
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.gifUrl,
    required this.targetMuscles,
    required this.bodyParts,
    required this.equipments,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'] ?? '',
      name: json['name'] ?? '',
      gifUrl: json['gifUrl'] ?? '',
      targetMuscles: List<String>.from(json['targetMuscles'] ?? []),
      bodyParts: List<String>.from(json['bodyParts'] ?? []),
      equipments: List<String>.from(json['equipments'] ?? []),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'gifUrl': gifUrl,
      'targetMuscles': targetMuscles,
      'bodyParts': bodyParts,
      'equipments': equipments,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
    };
  }

  // UI helper methods
  IconData get exerciseIcon {
    if (bodyParts.any((part) => part.toLowerCase().contains('chest'))) {
      return Icons.fitness_center;
    } else if (bodyParts.any((part) => part.toLowerCase().contains('back'))) {
      return Icons.airline_seat_recline_normal;
    } else if (bodyParts.any((part) => part.toLowerCase().contains('arm'))) {
      return Icons.sports_martial_arts;
    } else if (bodyParts.any((part) => part.toLowerCase().contains('leg'))) {
      return Icons.directions_run;
    } else if (bodyParts.any((part) => part.toLowerCase().contains('core'))) {
      return Icons.center_focus_strong;
    } else {
      return Icons.fitness_center;
    }
  }

  Color get primaryMuscleColor {
    if (targetMuscles.isNotEmpty) {
      final muscle = targetMuscles.first.toLowerCase();
      if (muscle.contains('chest')) return Colors.red;
      if (muscle.contains('back')) return Colors.blue;
      if (muscle.contains('arm') || muscle.contains('bicep') || muscle.contains('tricep')) return Colors.orange;
      if (muscle.contains('leg') || muscle.contains('quad') || muscle.contains('hamstring')) return Colors.green;
      if (muscle.contains('core') || muscle.contains('abs')) return Colors.purple;
      if (muscle.contains('shoulder')) return Colors.teal;
    }
    return Colors.grey;
  }

  String get primaryBodyPart => bodyParts.isNotEmpty ? bodyParts.first : 'General';
  
  String get primaryTargetMuscle => targetMuscles.isNotEmpty ? targetMuscles.first : 'General';
  
  String get primaryEquipment => equipments.isNotEmpty ? equipments.first : 'No equipment';

  String get targetMusclesDisplay => targetMuscles.join(', ');
  
  String get bodyPartsDisplay => bodyParts.join(', ');
  
  String get equipmentsDisplay => equipments.join(', ');
}

/// Model for ExerciseDB API response
class ExerciseApiResponse {
  final bool success;
  final ExerciseApiMetadata metadata;
  final List<Exercise> data;

  ExerciseApiResponse({
    required this.success,
    required this.metadata,
    required this.data,
  });

  factory ExerciseApiResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseApiResponse(
      success: json['success'] ?? false,
      metadata: ExerciseApiMetadata.fromJson(json['metadata'] ?? {}),
      data: (json['data'] as List<dynamic>?)
          ?.map((exerciseJson) => Exercise.fromJson(exerciseJson))
          .toList() ?? [],
    );
  }
}

/// Model for ExerciseDB API metadata
class ExerciseApiMetadata {
  final int totalExercises;
  final int totalPages;
  final int currentPage;
  final String? previousPage;
  final String? nextPage;

  ExerciseApiMetadata({
    required this.totalExercises,
    required this.totalPages,
    required this.currentPage,
    this.previousPage,
    this.nextPage,
  });

  factory ExerciseApiMetadata.fromJson(Map<String, dynamic> json) {
    return ExerciseApiMetadata(
      totalExercises: json['totalExercises'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      previousPage: json['previousPage'],
      nextPage: json['nextPage'],
    );
  }
}
