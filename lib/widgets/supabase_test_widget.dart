import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user.dart';

class SupabaseTestWidget extends StatefulWidget {
  const SupabaseTestWidget({super.key});

  @override
  State<SupabaseTestWidget> createState() => _SupabaseTestWidgetState();
}

class _SupabaseTestWidgetState extends State<SupabaseTestWidget> {
  String _connectionStatus = 'Not tested';
  String _usersInfo = '';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Testing...';
      _usersInfo = '';
    });

    try {
      // Test basic connection
      final isConnected = await DatabaseService.testConnection();
      
      if (isConnected) {
        // Try to get users count (READ ONLY)
        final users = await DatabaseService.getAllUsers();
        
        setState(() {
          _connectionStatus = '✅ Connected to Supabase!';
          if (users != null) {
            _usersInfo = '📊 Found ${users.length} users in database\n';
            if (users.isNotEmpty) {
              final roleCount = <String, int>{};
              for (var user in users) {
                roleCount[user.role] = (roleCount[user.role] ?? 0) + 1;
              }
              _usersInfo += 'Roles: ${roleCount.entries.map((e) => '${e.key}: ${e.value}').join(', ')}';
            }
          } else {
            _usersInfo = '⚠️ Connected but could not read users table';
          }
        });
      } else {
        setState(() {
          _connectionStatus = '❌ Connection failed';
          _usersInfo = '';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Error: $e';
        _usersInfo = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Supabase Connection Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: $_connectionStatus',
              style: TextStyle(
                fontSize: 16,
                color: _connectionStatus.contains('✅') 
                    ? Colors.green 
                    : _connectionStatus.contains('❌') 
                        ? Colors.red 
                        : Colors.orange,
              ),
            ),
            if (_usersInfo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _usersInfo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Users Table'),
            ),
          ],
        ),
      ),
    );
  }
}