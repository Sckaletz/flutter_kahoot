import 'package:flutter/material.dart';

void main() {
  runApp(const KahootApp());
}

class KahootApp extends StatelessWidget {
  const KahootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // fjerner "Debug" banneret i hjørnet, så det ser pro ud
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('Her skal vores Kahoot startskærm være')),
      ),
    );
  }
}
