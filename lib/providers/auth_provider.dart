import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/job_seeker/job_seeker_home.dart';
import '../screens/auth/login_screen.dart';
import '../screens/recruiter/recruiter_home.dart';
import '../screens/auth/profile_setup_screen.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> register(String email, String password, {String role = 'job_seeker'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'role': role},
      );

      if (response.user != null) {
        final userData = await _supabase
            .from('profiles')
            .select('id, role, phone, photo_url')
            .eq('email', email)
            .single();

        _user = AppUser(
          id: userData['id'], // id is now a String (UUID)
          name: response.user!.userMetadata?['name'] ?? 'User',
          email: response.user!.email!,
          phone: userData['phone'] ?? '',
          role: userData['role'] ?? 'job_seeker',
          profileStatus: 'Active',
          photoUrl: userData['photo_url'],
        );
        _token = response.session?.accessToken;

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final idToken = response.session?.accessToken;

        final userData = await _supabase
            .from('profiles')
            .select('id, role, phone, photo_url')
            .eq('email', email)
            .single();

        _user = AppUser(
          id: userData['id'], // id is now a String (UUID)
          name: response.user!.userMetadata?['name'] ?? 'User',
          email: response.user!.email!,
          phone: userData['phone'] ?? '',
          role: userData['role'] ?? 'job_seeker',
          profileStatus: 'Active',
          photoUrl: userData['photo_url'],
        );
        _token = idToken;

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      if (!success) {
        _error = 'Failed to initiate Google sign-in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await Future.delayed(const Duration(seconds: 1));

      final session = _supabase.auth.currentSession;
      if (session != null && _supabase.auth.currentUser != null) {
        final idToken = session.accessToken;

        final userData = await _supabase
            .from('profiles')
            .select('id, role, phone, photo_url')
            .eq('email', _supabase.auth.currentUser!.email!)
            .single();

        _user = AppUser(
          id: userData['id'], // id is now a String (UUID)
          name: _supabase.auth.currentUser!.userMetadata?['full_name'] ?? 'User',
          email: _supabase.auth.currentUser!.email!,
          phone: userData['phone'] ?? '',
          role: userData['role'] ?? 'job_seeker',
          profileStatus: 'Active',
          photoUrl: userData['photo_url'] ?? _supabase.auth.currentUser!.userMetadata?['avatar_url'],
        );
        _token = idToken;

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);

        _isLoading = false;
        notifyListeners();

        navigateToRoleBasedHome(context);
        return true;
      } else {
        _error = 'Google sign-in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> autoLogin(String savedToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = _supabase.auth.currentSession;
      final currentUser = _supabase.auth.currentUser;

      if (session != null && currentUser != null && session.accessToken == savedToken) {
        final userData = await _supabase
            .from('profiles')
            .select('id, role, phone, photo_url')
            .eq('email', currentUser.email!)
            .single();

        _user = AppUser(
          id: userData['id'], // id is now a String (UUID)
          name: currentUser.userMetadata?['name'] ?? 'User',
          email: currentUser.email!,
          phone: userData['phone'] ?? '',
          role: userData['role'] ?? 'job_seeker',
          profileStatus: 'Active',
          photoUrl: userData['photo_url'],
        );
        _token = savedToken;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _token = null;
        _user = null;

        final prefs = await SharedPreferences.getInstance();
        prefs.remove('auth_token');

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _token = null;
      _user = null;

      final prefs = await SharedPreferences.getInstance();
      prefs.remove('auth_token');

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.signOut();

      _user = null;
      _token = null;

      final prefs = await SharedPreferences.getInstance();
      prefs.remove('auth_token');

      _isLoading = false;
      notifyListeners();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyRole(String requiredRole) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', _supabase.auth.currentUser!.id)
          .single();
      return response['role'] == requiredRole;
    } catch (e) {
      return false;
    }
  }

  void navigateToRoleBasedHome(BuildContext context) async {
    if (_user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
      return;
    }

    if (_user!.phone.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(isMandatory: true),
        ),
      );
      return;
    }

    Widget homeScreen;
    switch (_user!.role) {
      case 'job_seeker':
        homeScreen = JobSeekerHomeScreen();
        break;
      case 'recruiter':
        homeScreen = RecruiterHomeScreen();
        break;
      case 'admin':
        bool isAdmin = await verifyRole('admin');
        if (!isAdmin) {
          homeScreen = LoginScreen();
          break;
        }
        homeScreen = AdminHomeScreen();
        break;
      default:
        homeScreen = LoginScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => homeScreen),
      (route) => false,
    );
  }

  void updateUserProfile(AppUser updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}