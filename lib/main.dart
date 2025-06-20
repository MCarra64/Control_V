import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const VerdureriaElAhorroApp());
}

class VerdureriaElAhorroApp extends StatelessWidget {
  const VerdureriaElAhorroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verdurería el Ahorro',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}