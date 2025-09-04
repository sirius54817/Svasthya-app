import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Emergency contact controllers
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  final _emergencyEmailController = TextEditingController();
  
  // Medical history controllers
  final _conditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _surgeriesController = TextEditingController();
  final _familyHistoryController = TextEditingController();
  
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  String? _selectedSubscriptionType;
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyEmailController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _bloodTypeController.dispose();
    _medicalNotesController.dispose();
    _surgeriesController.dispose();
    _familyHistoryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('🔄 Loading user profile...');
      final profile = await DatabaseService.getCurrentUserProfile();
      
      if (profile != null) {
        print('✅ Profile found: ${profile.fullName}');
        _populateFields(profile);
      } else {
        print('ℹ️ No profile found for current user');
      }
      
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadUserProfile,
            ),
          ),
        );
      }
    }
  }

  void _populateFields(UserProfile profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone ?? '';
    _addressController.text = profile.address ?? '';
    _selectedDateOfBirth = profile.dateOfBirth;
    _selectedGender = profile.gender;
    _selectedSubscriptionType = profile.subscriptionType;
    
    // Emergency contact
    if (profile.emergencyContact != null) {
      _emergencyNameController.text = profile.emergencyContact!.name;
      _emergencyPhoneController.text = profile.emergencyContact!.phone;
      _emergencyRelationshipController.text = profile.emergencyContact!.relationship ?? '';
      _emergencyEmailController.text = profile.emergencyContact!.email ?? '';
    }
    
    // Medical history
    if (profile.medicalHistory != null) {
      _conditionsController.text = profile.medicalHistory!.conditions.join(', ');
      _allergiesController.text = profile.medicalHistory!.allergies.join(', ');
      _medicationsController.text = profile.medicalHistory!.medications.join(', ');
      _bloodTypeController.text = profile.medicalHistory!.bloodType ?? '';
      _medicalNotesController.text = profile.medicalHistory!.notes ?? '';
      _surgeriesController.text = profile.medicalHistory!.previousSurgeries.join(', ');
      _familyHistoryController.text = profile.medicalHistory!.familyHistory.join(', ');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Create emergency contact
      EmergencyContact? emergencyContact;
      if (_emergencyNameController.text.isNotEmpty && _emergencyPhoneController.text.isNotEmpty) {
        emergencyContact = EmergencyContact(
          name: _emergencyNameController.text,
          phone: _emergencyPhoneController.text,
          relationship: _emergencyRelationshipController.text.isNotEmpty 
              ? _emergencyRelationshipController.text 
              : null,
          email: _emergencyEmailController.text.isNotEmpty 
              ? _emergencyEmailController.text 
              : null,
        );
      }

      // Create medical history
      MedicalHistory? medicalHistory;
      if (_conditionsController.text.isNotEmpty ||
          _allergiesController.text.isNotEmpty ||
          _medicationsController.text.isNotEmpty ||
          _bloodTypeController.text.isNotEmpty ||
          _medicalNotesController.text.isNotEmpty ||
          _surgeriesController.text.isNotEmpty ||
          _familyHistoryController.text.isNotEmpty) {
        medicalHistory = MedicalHistory(
          conditions: _conditionsController.text.isNotEmpty 
              ? _conditionsController.text.split(',').map((e) => e.trim()).toList()
              : [],
          allergies: _allergiesController.text.isNotEmpty 
              ? _allergiesController.text.split(',').map((e) => e.trim()).toList()
              : [],
          medications: _medicationsController.text.isNotEmpty 
              ? _medicationsController.text.split(',').map((e) => e.trim()).toList()
              : [],
          bloodType: _bloodTypeController.text.isNotEmpty 
              ? _bloodTypeController.text 
              : null,
          notes: _medicalNotesController.text.isNotEmpty 
              ? _medicalNotesController.text 
              : null,
          previousSurgeries: _surgeriesController.text.isNotEmpty 
              ? _surgeriesController.text.split(',').map((e) => e.trim()).toList()
              : [],
          familyHistory: _familyHistoryController.text.isNotEmpty 
              ? _familyHistoryController.text.split(',').map((e) => e.trim()).toList()
              : [],
        );
      }

      // Create updated profile
      final updatedProfile = UserProfile(
        id: _userProfile?.id ?? '',
        userId: Supabase.instance.client.auth.currentUser?.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        dateOfBirth: _selectedDateOfBirth,
        gender: _selectedGender,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        avatarUrl: _userProfile?.avatarUrl,
        emergencyContact: emergencyContact,
        medicalHistory: medicalHistory,
        subscriptionType: _selectedSubscriptionType,
        createdAt: _userProfile?.createdAt,
        updatedAt: DateTime.now(),
      );

      UserProfile? savedProfile;
      if (_userProfile == null) {
        // Create new profile
        savedProfile = await DatabaseService.createUserProfile(updatedProfile);
      } else {
        // Update existing profile
        savedProfile = await DatabaseService.updateUserProfile(updatedProfile);
      }

      if (savedProfile != null) {
        setState(() {
          _userProfile = savedProfile;
          _isEditing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to save profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
          ),
          if (_userProfile != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userProfile == null && !_isEditing
                ? _buildCreateProfilePrompt()
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildCreateProfilePrompt() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Create Your Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your profile to get personalized\nhealthcare recommendations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _loadUserProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_isEditing) {
      return _buildEditForm();
    } else {
      return _buildProfileView();
    }
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _buildProfileHeader(),
          const SizedBox(height: 24),
          
          // Basic information
          _buildInfoSection(
            'Basic Information',
            Icons.person,
            [
              _buildInfoRow('Name', _userProfile!.fullName.isNotEmpty ? _userProfile!.fullName : 'Not provided', Icons.person_outline),
              _buildInfoRow('Phone', _userProfile!.phone ?? 'Not provided', Icons.phone),
              _buildInfoRow('Date of Birth', 
                  _userProfile!.dateOfBirth != null 
                      ? '${_userProfile!.dateOfBirth!.day}/${_userProfile!.dateOfBirth!.month}/${_userProfile!.dateOfBirth!.year}'
                      : 'Not provided', Icons.cake),
              _buildInfoRow('Age', _userProfile!.age?.toString() ?? 'Not available', Icons.calendar_today),
              _buildInfoRow('Gender', _userProfile!.genderDisplay, Icons.wc),
              _buildInfoRow('Address', _userProfile!.address ?? 'Not provided', Icons.location_on),
              _buildInfoRow('Subscription', _userProfile!.subscriptionTypeDisplay, Icons.card_membership),
            ],
          ),
          
          // Emergency contact
          if (_userProfile!.emergencyContact != null) ...[
            const SizedBox(height: 24),
            _buildInfoSection(
              'Emergency Contact',
              Icons.emergency,
              [
                _buildInfoRow('Name', _userProfile!.emergencyContact!.name ?? 'Not provided', Icons.person),
                _buildInfoRow('Phone', _userProfile!.emergencyContact!.phone ?? 'Not provided', Icons.phone),
                _buildInfoRow('Relationship', _userProfile!.emergencyContact!.relationship ?? 'Not specified', Icons.family_restroom),
                _buildInfoRow('Email', _userProfile!.emergencyContact!.email ?? 'Not provided', Icons.email),
              ],
            ),
          ] else ...[
            const SizedBox(height: 24),
            _buildEmptySection(
              'Emergency Contact',
              Icons.emergency,
              'No emergency contact information provided',
              'Add emergency contact details for safety',
            ),
          ],
          
          // Medical history
          if (_userProfile!.medicalHistory != null && _userProfile!.medicalHistory!.hasData) ...[
            const SizedBox(height: 24),
            _buildInfoSection(
              'Medical History',
              Icons.medical_services,
              [
                if (_userProfile!.medicalHistory!.bloodType != null)
                  _buildInfoRow('Blood Type', _userProfile!.medicalHistory!.bloodType!, Icons.bloodtype),
                if (_userProfile!.medicalHistory!.conditions.isNotEmpty)
                  _buildInfoRow('Conditions', _userProfile!.medicalHistory!.conditions.join(', '), Icons.health_and_safety),
                if (_userProfile!.medicalHistory!.allergies.isNotEmpty)
                  _buildInfoRow('Allergies', _userProfile!.medicalHistory!.allergies.join(', '), Icons.warning),
                if (_userProfile!.medicalHistory!.medications.isNotEmpty)
                  _buildInfoRow('Current Medications', _userProfile!.medicalHistory!.medications.join(', '), Icons.medication),
                if (_userProfile!.medicalHistory!.previousSurgeries.isNotEmpty)
                  _buildInfoRow('Previous Surgeries', _userProfile!.medicalHistory!.previousSurgeries.join(', '), Icons.medical_services),
                if (_userProfile!.medicalHistory!.familyHistory.isNotEmpty)
                  _buildInfoRow('Family History', _userProfile!.medicalHistory!.familyHistory.join(', '), Icons.family_restroom),
                if (_userProfile!.medicalHistory!.notes != null)
                  _buildInfoRow('Notes', _userProfile!.medicalHistory!.notes!, Icons.note),
              ],
            ),
          ] else ...[
            const SizedBox(height: 24),
            _buildEmptySection(
              'Medical History',
              Icons.medical_services,
              'No medical history provided',
              'Add medical information for better healthcare',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: _userProfile!.avatarUrl != null 
                      ? NetworkImage(_userProfile!.avatarUrl!) 
                      : null,
                  child: _userProfile!.avatarUrl == null 
                      ? Text(
                          _userProfile!.firstName.isNotEmpty && _userProfile!.lastName.isNotEmpty
                              ? _userProfile!.firstName[0].toUpperCase() + 
                                _userProfile!.lastName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userProfile!.fullName.isNotEmpty ? _userProfile!.fullName : 'No Name Set',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userProfile!.subscriptionTypeDisplay,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_userProfile!.phone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              _userProfile!.phone!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusChip(
                  'Profile',
                  _userProfile!.isProfileComplete ? 'Complete' : 'Incomplete',
                  _userProfile!.isProfileComplete ? Colors.green : Colors.orange,
                ),
                if (_userProfile!.age != null)
                  _buildStatusChip('Age', '${_userProfile!.age} years', Colors.blue),
                if (_userProfile!.emergencyContact != null)
                  _buildStatusChip('Emergency', 'Contact Set', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String title, IconData icon, String message, String description) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: icon != null ? 100 : 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not provided',
              style: TextStyle(
                fontSize: 16,
                color: value.isNotEmpty ? Colors.black87 : Colors.grey[500],
                fontStyle: value.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information
            _buildFormSection(
              'Basic Information',
              [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDateOfBirth ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDateOfBirth = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedDateOfBirth != null
                          ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                          : 'Select date',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSubscriptionType,
                  decoration: const InputDecoration(
                    labelText: 'Subscription Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'basic', child: Text('Basic Plan')),
                    DropdownMenuItem(value: 'premium', child: Text('Premium Plan')),
                    DropdownMenuItem(value: 'ultimate', child: Text('Ultimate Plan')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubscriptionType = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Emergency Contact
            _buildFormSection(
              'Emergency Contact',
              [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyRelationshipController,
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Medical History
            _buildFormSection(
              'Medical History',
              [
                TextFormField(
                  controller: _bloodTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Type',
                    hintText: 'e.g., A+, B-, O+',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conditionsController,
                  decoration: const InputDecoration(
                    labelText: 'Medical Conditions',
                    hintText: 'Separate multiple conditions with commas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _allergiesController,
                  decoration: const InputDecoration(
                    labelText: 'Allergies',
                    hintText: 'Separate multiple allergies with commas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _medicationsController,
                  decoration: const InputDecoration(
                    labelText: 'Current Medications',
                    hintText: 'Separate multiple medications with commas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _surgeriesController,
                  decoration: const InputDecoration(
                    labelText: 'Previous Surgeries',
                    hintText: 'Separate multiple surgeries with commas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _familyHistoryController,
                  decoration: const InputDecoration(
                    labelText: 'Family Medical History',
                    hintText: 'Separate multiple conditions with commas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _medicalNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        if (_userProfile != null) {
                          _populateFields(_userProfile!);
                        }
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}