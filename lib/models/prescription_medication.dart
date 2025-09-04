import 'package:flutter/material.dart';

class PrescriptionMedication {
  final String id;
  final String? prescriptionId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? specialInstructions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PrescriptionMedication({
    required this.id,
    this.prescriptionId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.specialInstructions,
    this.createdAt,
    this.updatedAt,
  });

  factory PrescriptionMedication.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedication(
      id: json['id'],
      prescriptionId: json['prescription_id'],
      medicationName: json['medication_name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
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
      'medication_name': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'special_instructions': specialInstructions,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods for UI display
  String get displayName => medicationName;

  String get fullDosageInfo => '$dosage - $frequency';

  String get scheduleInfo => 'Take $frequency for $duration';

  // Get icon based on medication type (simplified categorization)
  IconData get medicationIcon {
    final lowerName = medicationName.toLowerCase();
    
    // Pain medications
    if (lowerName.contains('aspirin') || 
        lowerName.contains('ibuprofen') || 
        lowerName.contains('acetaminophen') ||
        lowerName.contains('paracetamol') ||
        lowerName.contains('pain')) {
      return Icons.healing;
    }
    
    // Antibiotics
    if (lowerName.contains('antibiotic') ||
        lowerName.contains('amoxicillin') ||
        lowerName.contains('penicillin') ||
        lowerName.contains('azithromycin')) {
      return Icons.shield;
    }
    
    // Heart medications
    if (lowerName.contains('blood pressure') ||
        lowerName.contains('heart') ||
        lowerName.contains('cardiac') ||
        lowerName.contains('amlodipine') ||
        lowerName.contains('lisinopril')) {
      return Icons.favorite;
    }
    
    // Diabetes medications
    if (lowerName.contains('diabetes') ||
        lowerName.contains('insulin') ||
        lowerName.contains('metformin') ||
        lowerName.contains('glucose')) {
      return Icons.water_drop;
    }
    
    // Respiratory medications
    if (lowerName.contains('inhaler') ||
        lowerName.contains('asthma') ||
        lowerName.contains('respiratory') ||
        lowerName.contains('albuterol')) {
      return Icons.air;
    }
    
    // Vitamins and supplements
    if (lowerName.contains('vitamin') ||
        lowerName.contains('supplement') ||
        lowerName.contains('calcium') ||
        lowerName.contains('omega')) {
      return Icons.eco;
    }
    
    // Default medication icon
    return Icons.medication;
  }

  // Get color based on frequency urgency
  Color get frequencyColor {
    final lowerFreq = frequency.toLowerCase();
    
    // Multiple times per day - high frequency (red)
    if (lowerFreq.contains('4 times') || 
        lowerFreq.contains('every 6 hours') ||
        lowerFreq.contains('every 4 hours') ||
        lowerFreq.contains('every 3 hours')) {
      return Colors.red;
    }
    
    // Three times per day - medium-high frequency (orange)
    if (lowerFreq.contains('3 times') || 
        lowerFreq.contains('every 8 hours') ||
        lowerFreq.contains('three times')) {
      return Colors.orange;
    }
    
    // Twice per day - medium frequency (amber)
    if (lowerFreq.contains('2 times') || 
        lowerFreq.contains('twice') ||
        lowerFreq.contains('every 12 hours') ||
        lowerFreq.contains('bid')) {
      return Colors.amber;
    }
    
    // Once per day - low frequency (green)
    if (lowerFreq.contains('once') || 
        lowerFreq.contains('daily') ||
        lowerFreq.contains('every 24 hours') ||
        lowerFreq.contains('1 time')) {
      return Colors.green;
    }
    
    // As needed - variable frequency (orange)
    if (lowerFreq.contains('as needed') || 
        lowerFreq.contains('prn') ||
        lowerFreq.contains('when required')) {
      return const Color(0xFFE67E22); // Orange - Primary theme color
    }
    
    // Default color
    return Colors.grey;
  }

  // Get priority level for sorting
  int get priorityLevel {
    final lowerFreq = frequency.toLowerCase();
    
    if (lowerFreq.contains('4 times') || 
        lowerFreq.contains('every 6 hours') ||
        lowerFreq.contains('every 4 hours') ||
        lowerFreq.contains('every 3 hours')) {
      return 1; // Highest priority
    }
    
    if (lowerFreq.contains('3 times') || 
        lowerFreq.contains('every 8 hours')) {
      return 2;
    }
    
    if (lowerFreq.contains('2 times') || 
        lowerFreq.contains('twice') ||
        lowerFreq.contains('every 12 hours')) {
      return 3;
    }
    
    if (lowerFreq.contains('once') || 
        lowerFreq.contains('daily')) {
      return 4;
    }
    
    return 5; // Lowest priority (as needed, etc.)
  }

  // Check if medication has special instructions
  bool get hasSpecialInstructions => 
      specialInstructions != null && specialInstructions!.isNotEmpty;

  // Get formatted duration display
  String get durationDisplay {
    final lowerDuration = duration.toLowerCase();
    
    if (lowerDuration.contains('day')) {
      return duration;
    }
    
    if (lowerDuration.contains('week')) {
      return duration;
    }
    
    if (lowerDuration.contains('month')) {
      return duration;
    }
    
    if (lowerDuration.contains('ongoing') || 
        lowerDuration.contains('indefinite') ||
        lowerDuration.contains('continuous')) {
      return 'Ongoing';
    }
    
    return duration;
  }

  // Copy with method for updates
  PrescriptionMedication copyWith({
    String? id,
    String? prescriptionId,
    String? medicationName,
    String? dosage,
    String? frequency,
    String? duration,
    String? specialInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrescriptionMedication(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PrescriptionMedication{id: $id, medicationName: $medicationName, dosage: $dosage, frequency: $frequency}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionMedication &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}