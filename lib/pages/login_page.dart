import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user.dart' as app_models;
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Sign in with Supabase Auth
      final authResponse = await DatabaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (authResponse != null && authResponse.user != null) {
        // Get user data from the users table
        final user = await DatabaseService.getUserByEmail(
          _emailController.text.trim(),
        );

        if (user != null && mounted) {
          // Navigate to appropriate dashboard based on role
          _navigateBasedOnRole(user);
        } else {
          setState(() {
            _errorMessage = 'User profile not found. Please contact support.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateBasedOnRole(app_models.User user) {
    // TODO: Replace with actual navigation routes based on user role
    switch (user.role) {
      case 'patient':
        // Navigator.pushReplacementNamed(context, '/patient-dashboard');
        _showSuccessDialog('Welcome Patient!', 'Patient dashboard coming soon...');
        break;
      case 'doctor':
        // Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        _showSuccessDialog('Welcome Doctor!', 'Doctor dashboard coming soon...');
        break;
      case 'admin':
        // Navigator.pushReplacementNamed(context, '/admin-dashboard');
        _showSuccessDialog('Welcome Admin!', 'Admin dashboard coming soon...');
        break;
      default:
        setState(() {
          _errorMessage = 'Unknown user role. Please contact support.';
        });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly cooler background like the dashboard
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFF1F3F4),
              Color(0xFFECEFF1),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title - Enhanced with better shadow like dashboard cards
                  Container(
                    decoration: AppTheme.primaryCardShadow,
                    padding: const EdgeInsets.all(40),
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x20E67E22),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.health_and_safety,
                            size: 72,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Svasthya',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Healthcare Management System',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Login Form - Enhanced with dashboard-style shadow
                  Container(
                    decoration: AppTheme.cardShadow,
                    padding: const EdgeInsets.all(36),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to your account',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Email Field - Enhanced with better validation
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field - Enhanced with better styling
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(
                                Icons.lock_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Error Message - Enhanced with better styling
                          if (_errorMessage != null) ...[
                            Container(
                              decoration: AppTheme.errorCardShadow,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: theme.colorScheme.error,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Login Button - Enhanced with better design
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Forgot Password Link - Enhanced styling
                          // Center(
                          //   child: TextButton(
                          //     onPressed: () {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //           content: const Text('Forgot password feature coming soon!'),
                          //           backgroundColor: theme.colorScheme.secondary,
                          //           behavior: SnackBarBehavior.floating,
                          //         ),
                          //       );
                          //     },
                          //     child: Text(
                          //       'Forgot Password?',
                          //       style: TextStyle(
                          //         color: theme.colorScheme.primary,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Section - Enhanced with better design
                  // Container(
                  //   decoration: AppTheme.cardShadow,
                  //   padding: const EdgeInsets.all(24),
                  //   child: Column(
                  //     children: [
                  //       Text(
                  //         "Don't have an account?",
                  //         style: theme.textTheme.bodyMedium?.copyWith(
                  //           color: theme.colorScheme.onSurfaceVariant,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 12),
                  //       SizedBox(
                  //         width: double.infinity,
                  //         height: 48,
                  //         child: OutlinedButton(
                  //           onPressed: () {
                  //             ScaffoldMessenger.of(context).showSnackBar(
                  //               SnackBar(
                  //                 content: const Text('Sign up feature coming soon!'),
                  //                 backgroundColor: theme.colorScheme.secondary,
                  //                 behavior: SnackBarBehavior.floating,
                  //               ),
                  //             );
                  //           },
                  //           child: Text(
                  //             'Create Account',
                  //             style: TextStyle(
                  //               color: theme.colorScheme.primary,
                  //               fontWeight: FontWeight.w600,
                  //               fontSize: 16,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 32),

                  // Footer info
                  Center(
                    child: Text(
                      '© 2025 Svasthya Healthcare',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}