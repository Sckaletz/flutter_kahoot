import 'dart:async';
import 'package:flutter/material.dart';
import '../services/kahoot_api_service.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _apiService = KahootApiService();
  Timer? _pollTimer;
  String? _quizTitle;
  late final int _sessionId;
  late final int _participantId;
  late final String _nickname;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _sessionId = args['sessionId'] as int;
    _participantId = args['participantId'] as int;
    _nickname = args['nickname'] as String;
  }

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _checkSessionStatus();
    });
  }

  Future<void> _checkSessionStatus() async {
    try {
      // Get current question to check if quiz has started
      final question = await _apiService.getCurrentQuestion(_sessionId);
      
      // If question exists, quiz has started
      if (question != null && mounted) {
        _pollTimer?.cancel();
        Navigator.pushReplacementNamed(
          context,
          '/question',
          arguments: {
            'sessionId': _sessionId,
            'participantId': _participantId,
            'nickname': _nickname,
          },
        );
        return;
      }

      // Also check session status for completion
      // Note: We'd need a session endpoint, but for now we'll use question as indicator
    } catch (e) {
      // Ignore errors during polling
      debugPrint('Polling error: $e');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B2CBF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Waiting for host to start',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_quizTitle != null)
                  Text(
                    _quizTitle!,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 48),
                Text(
                  'You\'re in!',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your nickname: $_nickname',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
