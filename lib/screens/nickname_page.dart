import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../services/api_service.dart';

// Side hvor deltager kan indtaste et nickname og joine en session via PIN
class NicknamePage extends StatefulWidget {
  final String sessionPin;
  final String quizTitle;

  const NicknamePage({
    super.key,
    required this.sessionPin,
    required this.quizTitle,
  });

  @override
  State<NicknamePage> createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Participant? _joinSession;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _joinSessionHandler() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      setState(() {
        _errorMessage = 'Indtast venligst et nickname';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final joined = await joinSession(widget.sessionPin, nickname);
      if (!mounted) return;

      setState(() {
        _joinSession = joined;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Du er nu joined som ${joined.nickname}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join: ${widget.quizTitle}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PIN: ${widget.sessionPin}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'Skriv dit navn eller kaldenavn',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _joinSessionHandler,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Join session',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              if (_joinSession != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Joined som: ${_joinSession!.nickname}\nPoint: ${_joinSession!.totalPoints}',
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
