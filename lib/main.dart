import 'package:flutter/material.dart'; // design pakke der bruges til at lave UI'er
import 'screens/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guldgruppen Kahoot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 155, 120, 14),
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
