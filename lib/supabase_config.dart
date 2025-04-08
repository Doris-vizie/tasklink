// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseConfig {
//   static const String supabaseUrl = 'https://uzbmwmfgmpjmcsappeyv.supabase.co';
//   static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6Ym13bWZnbXBqbWNzYXBwZXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2MDQ0ODQsImV4cCI6MjA1OTE4MDQ4NH0.Nfi9ufF4JG82EGkqAFwkJ-WiCQzhrzU0HEUaFyo1DOM';

//   static Future<void> initialize() async {
//     await Supabase.initialize(
//       url: supabaseUrl,
//       anonKey: supabaseAnonKey,
//     );
//   }

//   static SupabaseClient get client => Supabase.instance.client;
// }