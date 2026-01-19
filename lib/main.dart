import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/join_session_screen.dart';
import 'screens/waiting_room_screen.dart';
import 'screens/question_screen.dart';
import 'screens/leaderboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kahoot Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B2CBF)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/join': (context) => const JoinSessionScreen(),
        '/waiting': (context) => const WaitingRoomScreen(),
        '/question': (context) => const QuestionScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
      },
    );
  }
}
