import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;

class DatabaseService {
  // Get Supabase client instance
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Getter for the client (useful for direct access if needed)
  static SupabaseClient get client => _client;
  
  // Example: Test connection to Supabase using users table
  static Future<bool> testConnection() async {
    try {
      // Simple READ query to test connection using the existing users table
      final _ = await _client
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

  // TEST: Get users count
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

  // USERS TABLE - FULL CRUD METHODS
  
  // Create a new user in the users table
  static Future<app_models.User?> createUser({
    required String email,
    required String role,
  }) async {
    try {
      final response = await _client
          .from('users')
          .insert({
            'email': email,
            'role': role,
          })
          .select()
          .single();
      
      final user = app_models.User.fromJson(response);
      print('✅ User created successfully: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error creating user: $e');
      return null;
    }
  }

  // Update user information
  static Future<app_models.User?> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      
      final user = app_models.User.fromJson(response);
      print('✅ User updated successfully: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error updating user: $e');
      return null;
    }
  }

  // Delete user
  static Future<bool> deleteUser(String userId) async {
    try {
      await _client
          .from('users')
          .delete()
          .eq('id', userId);
      print('✅ User deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }
  
  // Get all users
  static Future<List<app_models.User>?> getAllUsers() async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      
      final users = response.map((json) => app_models.User.fromJson(json)).toList();
      print('✅ Users fetched successfully: ${users.length} users found');
      return users;
    } catch (e) {
      print('❌ Error fetching users: $e');
      return null;
    }
  }

  // Get user by ID
  static Future<app_models.User?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();
      
      final user = app_models.User.fromJson(response);
      print('✅ User fetched by ID successfully: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error fetching user by ID: $e');
      return null;
    }
  }

  // Get user by email
  static Future<app_models.User?> getUserByEmail(String email) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('email', email)
          .single();
      
      final user = app_models.User.fromJson(response);
      print('✅ User fetched by email successfully: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error fetching user by email: $e');
      return null;
    }
  }

  // Get users by role
  static Future<List<app_models.User>?> getUsersByRole(String role) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('role', role)
          .order('created_at', ascending: false);
      
      final users = response.map((json) => app_models.User.fromJson(json)).toList();
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
  static app_models.User? getCurrentUser() {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      // For a complete User object, we'd need to fetch from the users table
      // This is a simplified version - consider using getUserByEmail() for complete data
      return app_models.User(
        id: currentUser.id,
        email: currentUser.email ?? '',
        role: 'patient', // Default role - should be fetched from database
        createdAt: DateTime.parse(currentUser.createdAt),
      );
    }
    return null;
  }
  
  // Check if user is authenticated
  static bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }
}