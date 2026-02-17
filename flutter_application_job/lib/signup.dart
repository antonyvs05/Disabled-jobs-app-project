import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'models/user_model.dart';
import 'services/firebase_service.dart';
import 'theme/app_colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.job_seeker;
  bool _isLoading = false;
  String? _errorMessage;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      } else if (password.length < 6) {
        _passwordStrength = 'Weak - too short';
        _passwordStrengthColor = Colors.red;
      } else {
        int strength = 0;
        // Check length (6+ characters)
        if (password.length >= 6) strength++;
        if (password.length >= 8) strength++;
        if (password.length >= 12) strength++;
        // Check for uppercase
        if (password.contains(RegExp(r'[A-Z]'))) strength++;
        // Check for lowercase
        if (password.contains(RegExp(r'[a-z]'))) strength++;
        // Check for numbers
        if (password.contains(RegExp(r'[0-9]'))) strength++;
        // Check for special characters
        if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

        if (strength < 3) {
          _passwordStrength = 'Weak';
          _passwordStrengthColor = Colors.red;
        } else if (strength < 5) {
          _passwordStrength = 'Fair';
          _passwordStrengthColor = Colors.orange;
        } else if (strength < 6) {
          _passwordStrength = 'Good';
          _passwordStrengthColor = Colors.amber;
        } else {
          _passwordStrength = 'Strong';
          _passwordStrengthColor = Colors.green;
        }
      }
    });
  }

  Future<void> _handleSignUp() async {
    // Validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create Firebase Auth user
      final userCredential = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Create user document in Firestore
      final user = User(
        id: userCredential.user!.uid,
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
        createdAt: DateTime.now(),
        skills: [],
        preferences: {},
        functionalNeeds: [],
      );

      await FirebaseService().createUser(user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context);
      }
    } on auth.FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'weak-password') {
          _errorMessage = 'Password is too weak';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'Email is already in use';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Invalid email format';
        } else {
          _errorMessage = e.message ?? 'Signup failed';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.accessible_forward,
                      size: 60,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  const Text(
                    'Join Access Work',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create your account today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // SignUp Form Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Error Message
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Colors.red.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_errorMessage != null) const SizedBox(height: 16),

                          // Name TextField
                          TextField(
                            controller: _nameController,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email TextField
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Role Dropdown
                          DropdownButtonFormField<UserRole>(
                            initialValue: _selectedRole,
                            disabledHint: _isLoading ? null : const Text(''),
                            decoration: InputDecoration(
                              labelText: 'I am a',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: UserRole.job_seeker,
                                child: Text('Job Seeker'),
                              ),
                              DropdownMenuItem(
                                value: UserRole.employer,
                                child: Text('Employer'),
                              ),
                            ],
                            onChanged: _isLoading ? null : (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password TextField
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            enabled: !_isLoading,
                            onChanged: _updatePasswordStrength,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Password Strength Indicator
                          if (_passwordStrength.isNotEmpty)
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _passwordController.text.length / 20,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _passwordStrength,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _passwordStrengthColor,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),

                          // Confirm Password TextField
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
