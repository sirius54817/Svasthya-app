import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

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
  static Future<List<User>?> getAllUsers() async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      
      final users = response.map((json) => User.fromJson(json)).toList();
      print('✅ Users fetched successfully: ${users.length} users found');
      return users;
    } catch (e) {
      print('❌ Error fetching users: $e');
      return null;
    }
  }

  // Get user by ID (READ ONLY)
  static Future<User?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();
      
      final user = User.fromJson(response);
      print('✅ User fetched by ID successfully: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error fetching user by ID: $e');
      return null;
    }
  }

  // Get user by email (READ ONLY)
  static Future<User?> getUserByEmail(String email) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('email', email)
          .single();
      
      final user = User.fromJson(response);
      print('✅ User fetched by email successfully: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error fetching user by email: $e');
      return null;
    }
  }

  // Get users by role (READ ONLY)
  static Future<List<User>?> getUsersByRole(String role) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('role', role)
          .order('created_at', ascending: false);
      
      final users = response.map((json) => User.fromJson(json)).toList();
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
}