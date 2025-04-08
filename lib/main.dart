import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasklink/screens/splash_screen.dart';
import 'providers/auth_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://uzbmwmfgmpjmcsappeyv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6Ym13bWZnbXBqbWNzYXBwZXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2MDQ0ODQsImV4cCI6MjA1OTE4MDQ4NH0.Nfi9ufF4JG82EGkqAFwkJ-WiCQzhrzU0HEUaFyo1DOM',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: SplashScreen(), // Set LoginScreen as the initial route
      ),
    );
  }
}

