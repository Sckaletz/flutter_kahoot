import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/quiz_session.dart';
import '../services/api_service.dart';

// HostPage viser en PIN til den valgte quiz og starter en ny session
class HostPage extends StatefulWidget {
  final Quiz quiz; // Quiz objekt der skal hostes

  const HostPage({super.key, required this.quiz});

  @override
  State<HostPage> createState() => _HostPageState(); // Opretter state objektet, der håndterer den faktiske tilstand
}

class _HostPageState extends State<HostPage> {
  QuizSession? _session;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Opretter automatisk en session (og PIN) når man går ind på siden
    _startSession();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Starter en ny session for den valgte quiz og henter PIN
  Future<void> _startSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await startSession(widget.quiz.id);
      setState(() {
        _session = session;
        _isLoading = false;
      });
      // Starter polling når session er oprettet
      _startPolling();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Starter automatisk polling for at opdatere session info (inkl. deltagerantal)
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_session != null) {
        _updateSession();
      }
    });
  }

  // Opdaterer session info ved at hente den opdaterede session via PIN
  Future<void> _updateSession() async {
    if (_session == null) return;

    try {
      final updatedSession = await fetchSessionByPin(_session!.sessionPin);
      if (mounted) {
        setState(() {
          _session = updatedSession;
        });
      }
    } catch (e) {
      // Ignorer fejl ved polling - vi vil ikke forstyrre UI'et
      // Session kan stadig være gyldig selvom polling fejler
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: Center(
        child: Padding(padding: const EdgeInsets.all(24), child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Fejl ved start af session',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _startSession,
            icon: const Icon(Icons.refresh),
            label: const Text('Prøv igen'),
          ),
        ],
      );
    }

    if (_session == null) {
      return const Text('Ingen session data tilgængelig');
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Session PIN',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            _session!.sessionPin,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Status: ${_session!.status}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Deltagere',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_session!.participantCount}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _session!.participantCount == 1
                        ? 'deltager'
                        : 'deltagere',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Opdaterer automatisk hver 2. sekund',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
