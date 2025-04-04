import 'package:flutter/material.dart';
import 'package:tasklink/auth/auth_gate.dart';
import 'package:tasklink/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const TaskLinkApp());
}

class TaskLinkApp extends StatelessWidget {
  const TaskLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthGate(),
    );
  }
}
