import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Get authservice
  final authService = AuthService();

  // Text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Sign up button respond
  void signUp() async {
    // prepare data
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Check if password and confirm password match
    if (password != confirmPassword) {
        ScaffoldMessenger.of(context)
        .showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
          ),
        );
      return;
    }

    // Attempt to sign up
    try {
      await authService.signUpWithEmailPassword(email, password);
      // Navigate to login screen
      Navigator.pop(context);
    }
    catch (e) {
      // Handle errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          // email
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ), 

          // password
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ), 

          // confirm password
          TextField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
            ),
            obscureText: true,
          ),

          const SizedBox(height: 12),

          // button
          ElevatedButton(
            onPressed: signUp,
            child: const Text('Sign Up'),
          ),

          const SizedBox(height: 12),

        ],
      ),
    );
  }
}
