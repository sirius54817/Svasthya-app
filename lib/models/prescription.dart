import 'package:flutter/material.dart';

class Prescription {
  final String id;
  final String? doctorId;
  final String? patientId;
  final String title;
  final String? description;
  final String type; // 'exercise', 'medication', 'combined'
  final String status; // 'active', 'completed', 'cancelled'
  final int? durationWeeks;
  final DateTime? followUpDate;
  final String? instructions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Prescription({
    required this.id,
    this.doctorId,
    this.patientId,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    this.durationWeeks,
    this.followUpDate,
    this.instructions,
    this.createdAt,
    this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String?,
      patientId: json['patient_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      status: json['status'] as String? ?? 'active',
      durationWeeks: json['duration_weeks'] as int?,
      followUpDate: json['follow_up_date'] != null 
          ? DateTime.parse(json['follow_up_date']) 
          : null,
      instructions: json['instructions'] as String?,
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
      'doctor_id': doctorId,
      'patient_id': patientId,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'duration_weeks': durationWeeks,
      'follow_up_date': followUpDate?.toIso8601String(),
      'instructions': instructions,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods for display
  String get typeDisplayName {
    switch (type) {
      case 'exercise':
        return 'Exercise';
      case 'medication':
        return 'Medication';
      case 'combined':
        return 'Combined';
      default:
        return type.toUpperCase();
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    switch (status) {
      case 'active':
        return const Color(0xFF4CAF50); // Green
      case 'completed':
        return const Color(0xFFE67E22); // Orange - Primary theme color
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'exercise':
        return Icons.fitness_center;
      case 'medication':
        return Icons.medication;
      case 'combined':
        return Icons.medical_services;
      default:
        return Icons.description;
    }
  }
}