class UserProfile {
  final String id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? avatarUrl;
  final EmergencyContact? emergencyContact;
  final MedicalHistory? medicalHistory;
  final String? subscriptionType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.avatarUrl,
    this.emergencyContact,
    this.medicalHistory,
    this.subscriptionType,
    this.createdAt,
    this.updatedAt,
  });

  // Full name getter
  String get fullName => '$firstName $lastName';

  // Age calculation
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Subscription type display
  String get subscriptionTypeDisplay {
    switch (subscriptionType?.toLowerCase()) {
      case 'basic':
        return 'Basic Plan';
      case 'premium':
        return 'Premium Plan';
      case 'ultimate':
        return 'Ultimate Plan';
      default:
        return 'No Subscription';
    }
  }

  // Gender display
  String get genderDisplay {
    switch (gender?.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  // Check if profile is complete
  bool get isProfileComplete {
    return firstName.isNotEmpty &&
           lastName.isNotEmpty &&
           phone != null &&
           phone!.isNotEmpty &&
           dateOfBirth != null &&
           gender != null &&
           address != null &&
           address!.isNotEmpty;
  }

  // Factory constructor from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      userId: json['user_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      gender: json['gender'],
      address: json['address'],
      avatarUrl: json['avatar_url'],
      emergencyContact: json['emergency_contact'] != null 
          ? EmergencyContact.fromJson(json['emergency_contact']) 
          : null,
      medicalHistory: json['medical_history'] != null 
          ? MedicalHistory.fromJson(json['medical_history']) 
          : null,
      subscriptionType: json['subscription_type'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0], // Date only
      'gender': gender,
      'address': address,
      'avatar_url': avatarUrl,
      'emergency_contact': emergencyContact?.toJson(),
      'medical_history': medicalHistory?.toJson(),
      'subscription_type': subscriptionType,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy with method for updates
  UserProfile copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? avatarUrl,
    EmergencyContact? emergencyContact,
    MedicalHistory? medicalHistory,
    String? subscriptionType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, fullName: $fullName, phone: $phone, subscriptionType: $subscriptionType)';
  }
}

// Emergency Contact model for JSONB field
class EmergencyContact {
  final String name;
  final String phone;
  final String? relationship;
  final String? email;

  EmergencyContact({
    required this.name,
    required this.phone,
    this.relationship,
    this.email,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'email': email,
    };
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    String? relationship,
    String? email,
  }) {
    return EmergencyContact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'EmergencyContact(name: $name, phone: $phone, relationship: $relationship)';
  }
}

// Medical History model for JSONB field
class MedicalHistory {
  final List<String> conditions;
  final List<String> allergies;
  final List<String> medications;
  final String? bloodType;
  final String? notes;
  final List<String> previousSurgeries;
  final List<String> familyHistory;

  MedicalHistory({
    this.conditions = const [],
    this.allergies = const [],
    this.medications = const [],
    this.bloodType,
    this.notes,
    this.previousSurgeries = const [],
    this.familyHistory = const [],
  });

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      conditions: json['conditions'] != null 
          ? List<String>.from(json['conditions']) 
          : [],
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies']) 
          : [],
      medications: json['medications'] != null 
          ? List<String>.from(json['medications']) 
          : [],
      bloodType: json['blood_type'],
      notes: json['notes'],
      previousSurgeries: json['previous_surgeries'] != null 
          ? List<String>.from(json['previous_surgeries']) 
          : [],
      familyHistory: json['family_history'] != null 
          ? List<String>.from(json['family_history']) 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions,
      'allergies': allergies,
      'medications': medications,
      'blood_type': bloodType,
      'notes': notes,
      'previous_surgeries': previousSurgeries,
      'family_history': familyHistory,
    };
  }

  MedicalHistory copyWith({
    List<String>? conditions,
    List<String>? allergies,
    List<String>? medications,
    String? bloodType,
    String? notes,
    List<String>? previousSurgeries,
    List<String>? familyHistory,
  }) {
    return MedicalHistory(
      conditions: conditions ?? this.conditions,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      bloodType: bloodType ?? this.bloodType,
      notes: notes ?? this.notes,
      previousSurgeries: previousSurgeries ?? this.previousSurgeries,
      familyHistory: familyHistory ?? this.familyHistory,
    );
  }

  // Check if medical history has any data
  bool get hasData {
    return conditions.isNotEmpty ||
           allergies.isNotEmpty ||
           medications.isNotEmpty ||
           (bloodType != null && bloodType!.isNotEmpty) ||
           (notes != null && notes!.isNotEmpty) ||
           previousSurgeries.isNotEmpty ||
           familyHistory.isNotEmpty;
  }

  @override
  String toString() {
    return 'MedicalHistory(conditions: ${conditions.length}, allergies: ${allergies.length}, bloodType: $bloodType)';
  }
}

// Enums for validation
enum Gender { male, female, other }
enum SubscriptionType { basic, premium, ultimate }

// Extension methods for enums
extension GenderExtension on Gender {
  String get value {
    switch (this) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
      case Gender.other:
        return 'other';
    }
  }

  String get display {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

extension SubscriptionTypeExtension on SubscriptionType {
  String get value {
    switch (this) {
      case SubscriptionType.basic:
        return 'basic';
      case SubscriptionType.premium:
        return 'premium';
      case SubscriptionType.ultimate:
        return 'ultimate';
    }
  }

  String get display {
    switch (this) {
      case SubscriptionType.basic:
        return 'Basic Plan';
      case SubscriptionType.premium:
        return 'Premium Plan';
      case SubscriptionType.ultimate:
        return 'Ultimate Plan';
    }
  }
}