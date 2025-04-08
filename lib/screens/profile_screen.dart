// import 'package:flutter/material.dart';


// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   // Get authservice
//   final authService = AuthService();

//   // Log out button pressed
//   void logout() async {
//     await authService.signOut();
//   }
//   @override
//   Widget build(BuildContext context) {

//     // Get user email
//     final currentEmail = authService.getCurrentUserEmail();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         actions: [
//           // log out button
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: logout
//         ),
//         ],
//       ),

//       body: Center(
//         child: Text(currentEmail.toString()),
//         ),
//     );
//   }
// }
