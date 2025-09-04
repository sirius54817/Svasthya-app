import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as UserModel;
import '../models/prescription.dart';
import '../models/prescription_medication.dart';

class DatabaseService {
  // Get Supabase client instance
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Getter for the client (useful for direct access if needed)
  static SupabaseClient get client => _client;
  
  // Example: Test connection to Supabase using users table (READ ONLY)
  static Future<bool> testConnection() async {
    try {
      // Simple READ query to test connection using the existing users table
      final response = await _client
          .from('users')
          .select('count(*)')
          .limit(1);
      print('✅ Supabase connection successful - users table accessible');
      return true;
    } catch (e) {
      print('❌ Supabase connection failed: $e');
      return false;
    }
  }

  // TEST: Get users count (READ ONLY - safe test)
  static Future<int> getUsersCount() async {
    try {
      final response = await _client
          .from('users')
          .select('count(*)')
          .limit(1);
      print('✅ Users count fetched successfully');
      return response.length;
    } catch (e) {
      print('❌ Error fetching users count: $e');
      return 0;
    }
  }

  // USERS TABLE - READ ONLY METHODS
  
  // Get all users (READ ONLY)
  static Future<List<UserModel.User>?> getAllUsers() async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      
      final users = response.map((json) => UserModel.User.fromJson(json)).toList();
      print('✅ Users fetched successfully: ${users.length} users found');
      return users;
    } catch (e) {
      print('❌ Error fetching users: $e');
      return null;
    }
  }

  // Get user by ID (READ ONLY)
  static Future<UserModel.User?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();
      
      final user = UserModel.User.fromJson(response);
      print('✅ User fetched by ID successfully: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error fetching user by ID: $e');
      return null;
    }
  }

  // Get user by email (READ ONLY)
  static Future<UserModel.User?> getUserByEmail(String email) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('email', email)
          .single();
      
      final user = UserModel.User.fromJson(response);
      print('✅ User fetched by email successfully: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error fetching user by email: $e');
      return null;
    }
  }

  // Get users by role (READ ONLY)
  static Future<List<UserModel.User>?> getUsersByRole(String role) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('role', role)
          .order('created_at', ascending: false);
      
      final users = response.map((json) => UserModel.User.fromJson(json)).toList();
      print('✅ Users by role fetched successfully: ${users.length} $role users found');
      return users;
    } catch (e) {
      print('❌ Error fetching users by role: $e');
      return null;
    }
  }
  
  // CRUD Operations Template (you can customize these based on your tables)
  
  // CREATE - Insert data into a table
  static Future<Map<String, dynamic>?> insertData(String tableName, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from(tableName)
          .insert(data)
          .select()
          .single();
      print('✅ Data inserted successfully: $response');
      return response;
    } catch (e) {
      print('❌ Error inserting data: $e');
      return null;
    }
  }
  
  // READ - Fetch all data from a table
  static Future<List<Map<String, dynamic>>?> getAllData(String tableName) async {
    try {
      final response = await _client
          .from(tableName)
          .select('*');
      print('✅ Data fetched successfully: ${response.length} records');
      return response;
    } catch (e) {
      print('❌ Error fetching data: $e');
      return null;
    }
  }
  
  // READ - Fetch data by ID
  static Future<Map<String, dynamic>?> getDataById(String tableName, String idColumn, dynamic id) async {
    try {
      final response = await _client
          .from(tableName)
          .select('*')
          .eq(idColumn, id)
          .single();
      print('✅ Data fetched by ID successfully: $response');
      return response;
    } catch (e) {
      print('❌ Error fetching data by ID: $e');
      return null;
    }
  }
  
  // UPDATE - Update data by ID
  static Future<Map<String, dynamic>?> updateData(
    String tableName, 
    String idColumn, 
    dynamic id, 
    Map<String, dynamic> updates
  ) async {
    try {
      final response = await _client
          .from(tableName)
          .update(updates)
          .eq(idColumn, id)
          .select()
          .single();
      print('✅ Data updated successfully: $response');
      return response;
    } catch (e) {
      print('❌ Error updating data: $e');
      return null;
    }
  }
  
  // DELETE - Delete data by ID
  static Future<bool> deleteData(String tableName, String idColumn, dynamic id) async {
    try {
      await _client
          .from(tableName)
          .delete()
          .eq(idColumn, id);
      print('✅ Data deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting data: $e');
      return false;
    }
  }
  
  // Authentication helpers
  
  // Sign up a new user
  static Future<AuthResponse?> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      print('✅ User signed up successfully');
      return response;
    } catch (e) {
      print('❌ Error signing up: $e');
      return null;
    }
  }
  
  // Sign in existing user
  static Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ User signed in successfully');
      return response;
    } catch (e) {
      print('❌ Error signing in: $e');
      return null;
    }
  }
  
  // Sign out current user
  static Future<bool> signOut() async {
    try {
      await _client.auth.signOut();
      print('✅ User signed out successfully');
      return true;
    } catch (e) {
      print('❌ Error signing out: $e');
      return false;
    }
  }
  
  // Get current user
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }
  
  // Check if user is authenticated
  static bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }

  // PRESCRIPTIONS TABLE METHODS
  
  // Get all prescriptions for current patient
  static Future<List<Prescription>?> getPatientPrescriptions() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return null;
      }

      final response = await _client
          .from('prescriptions')
          .select('*')
          .eq('patient_id', currentUser.id)
          .order('created_at', ascending: false);
      
      final prescriptions = response.map((json) => Prescription.fromJson(json)).toList();
      print('✅ Prescriptions fetched successfully: ${prescriptions.length} prescriptions found');
      return prescriptions;
    } catch (e) {
      print('❌ Error fetching prescriptions: $e');
      return null;
    }
  }

  // Get prescriptions by status for current patient
  static Future<List<Prescription>?> getPatientPrescriptionsByStatus(String status) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return null;
      }

      final response = await _client
          .from('prescriptions')
          .select('*')
          .eq('patient_id', currentUser.id)
          .eq('status', status)
          .order('created_at', ascending: false);
      
      final prescriptions = response.map((json) => Prescription.fromJson(json)).toList();
      print('✅ Prescriptions by status fetched successfully: ${prescriptions.length} $status prescriptions found');
      return prescriptions;
    } catch (e) {
      print('❌ Error fetching prescriptions by status: $e');
      return null;
    }
  }

  // Get prescriptions by type for current patient
  static Future<List<Prescription>?> getPatientPrescriptionsByType(String type) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return null;
      }

      final response = await _client
          .from('prescriptions')
          .select('*')
          .eq('patient_id', currentUser.id)
          .eq('type', type)
          .order('created_at', ascending: false);
      
      final prescriptions = response.map((json) => Prescription.fromJson(json)).toList();
      print('✅ Prescriptions by type fetched successfully: ${prescriptions.length} $type prescriptions found');
      return prescriptions;
    } catch (e) {
      print('❌ Error fetching prescriptions by type: $e');
      return null;
    }
  }

  // Get prescription by ID
  static Future<Prescription?> getPrescriptionById(String prescriptionId) async {
    try {
      final response = await _client
          .from('prescriptions')
          .select('*')
          .eq('id', prescriptionId)
          .single();
      
      final prescription = Prescription.fromJson(response);
      print('✅ Prescription fetched by ID successfully');
      return prescription;
    } catch (e) {
      print('❌ Error fetching prescription by ID: $e');
      return null;
    }
  }

  // PRESCRIPTION MEDICATIONS TABLE METHODS
  
  // Get all medications for current patient (across all prescriptions)
  static Future<List<PrescriptionMedication>?> getPatientMedications() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return null;
      }

      final response = await _client
          .from('prescription_medications')
          .select('''
            *,
            prescriptions!inner(patient_id)
          ''')
          .eq('prescriptions.patient_id', currentUser.id)
          .order('created_at', ascending: false);
      
      final medications = response.map((json) => PrescriptionMedication.fromJson(json)).toList();
      print('✅ Patient medications fetched successfully: ${medications.length} medications found');
      return medications;
    } catch (e) {
      print('❌ Error fetching patient medications: $e');
      return null;
    }
  }

  // Get medications for a specific prescription
  static Future<List<PrescriptionMedication>?> getMedicationsByPrescriptionId(String prescriptionId) async {
    try {
      final response = await _client
          .from('prescription_medications')
          .select('*')
          .eq('prescription_id', prescriptionId)
          .order('created_at', ascending: false);
      
      final medications = response.map((json) => PrescriptionMedication.fromJson(json)).toList();
      print('✅ Prescription medications fetched successfully: ${medications.length} medications found');
      return medications;
    } catch (e) {
      print('❌ Error fetching prescription medications: $e');
      return null;
    }
  }

  // Get medications by frequency (for current patient)
  static Future<List<PrescriptionMedication>?> getPatientMedicationsByFrequency(String frequency) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return null;
      }

      final response = await _client
          .from('prescription_medications')
          .select('''
            *,
            prescriptions!inner(patient_id)
          ''')
          .eq('prescriptions.patient_id', currentUser.id)
          .ilike('frequency', '%$frequency%')
          .order('created_at', ascending: false);
      
      final medications = response.map((json) => PrescriptionMedication.fromJson(json)).toList();
      print('✅ Patient medications by frequency fetched successfully: ${medications.length} medications found');
      return medications;
    } catch (e) {
      print('❌ Error fetching patient medications by frequency: $e');
      return null;
    }
  }

  // Search medications by name (for current patient)
  static Future<List<PrescriptionMedication>?> searchPatientMedications(String searchTerm) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return null;
      }

      final response = await _client
          .from('prescription_medications')
          .select('''
            *,
            prescriptions!inner(patient_id)
          ''')
          .eq('prescriptions.patient_id', currentUser.id)
          .ilike('medication_name', '%$searchTerm%')
          .order('created_at', ascending: false);
      
      final medications = response.map((json) => PrescriptionMedication.fromJson(json)).toList();
      print('✅ Patient medications search completed: ${medications.length} medications found');
      return medications;
    } catch (e) {
      print('❌ Error searching patient medications: $e');
      return null;
    }
  }

  // Get medication by ID
  static Future<PrescriptionMedication?> getMedicationById(String medicationId) async {
    try {
      final response = await _client
          .from('prescription_medications')
          .select('*')
          .eq('id', medicationId)
          .single();
      
      final medication = PrescriptionMedication.fromJson(response);
      print('✅ Medication fetched by ID successfully');
      return medication;
    } catch (e) {
      print('❌ Error fetching medication by ID: $e');
      return null;
    }
  }

  // Get active medications (for current patient) - excludes completed courses
  static Future<List<PrescriptionMedication>?> getActivePatientMedications() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('❌ No authenticated user');
        return null;
      }

      final response = await _client
          .from('prescription_medications')
          .select('''
            *,
            prescriptions!inner(patient_id, status)
          ''')
          .eq('prescriptions.patient_id', currentUser.id)
          .eq('prescriptions.status', 'active')
          .order('created_at', ascending: false);
      
      final medications = response.map((json) => PrescriptionMedication.fromJson(json)).toList();
      print('✅ Active patient medications fetched successfully: ${medications.length} medications found');
      return medications;
    } catch (e) {
      print('❌ Error fetching active patient medications: $e');
      return null;
    }
  }
}