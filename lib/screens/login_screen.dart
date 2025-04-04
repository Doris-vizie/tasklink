import 'package:flutter/material.dart';
import 'package:tasklink/auth/auth_service.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Get authservice
  final authService = AuthService();

  // Text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Login button respond
  void login() {
    // prepare data
    final email = _emailController.text;
    final password = _passwordController.text;

    // Attempt to login
    try {
      authService.signInWithEmailPassword(email, password);
    } 
    // Handle errors
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e')
          )
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
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

          const SizedBox(height: 12),

          // button
          ElevatedButton(
            onPressed: login,
            child: const Text('Login'),
          ),

          const SizedBox(height: 12),

          // register button
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (context) => const RegisterScreen(),
          )),
          child: const Center(child: Text("Don't have an account? Sign up!"))),

        ],
      ),
    );
  }
}

