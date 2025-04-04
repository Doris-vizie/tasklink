import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up a new user with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email, String password) async{
      return await _supabase.auth.signUp(
        email: email,
        password: password,
      );
  }

  // Sign in a user with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email, String password) async{
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
  }

  // Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.tasklink://login-callback/', // Optional: Custom redirect URI
      );
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user email 
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

}