import 'package:flutter/material.dart';
import 'package:tasklink/supabase_config.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const TaskLinkApp());
}

class TaskLinkApp extends StatelessWidget {
  const TaskLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskLink',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
        ),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
    );
  }
}
