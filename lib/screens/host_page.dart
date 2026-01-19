import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/quiz_session.dart';
import '../models/leaderboard.dart';
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
  bool _isStarting = false;
  String? _errorMessage;
  Timer? _pollingTimer;
  List<Leaderboard>? _leaderboard;
  bool _isLoadingLeaderboard = false;

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
      if (_session != null && !_isQuizStarted(_session!.status)) {
        _updateSession();
      } else {
        // Stop polling hvis quiz'en er startet
        timer.cancel();
      }
    });
  }

  // Opdaterer session info ved at hente den opdaterede session via PIN
  Future<void> _updateSession() async {
    if (_session == null) return;

    try {
      // Henter den opdaterede session via PIN
      final updatedSession = await fetchSessionByPin(_session!.sessionPin);
      if (mounted) {
        final wasStarted = _isQuizStarted(_session!.status);
        final isNowStarted = _isQuizStarted(updatedSession.status);

        setState(() {
          _session = updatedSession;
        });

        // Hvis quiz'en lige er startet, stop session polling og hent leaderboard
        if (!wasStarted && isNowStarted) {
          _pollingTimer?.cancel();
          _fetchLeaderboard();
        }
      }
    } catch (e) {
      // Ignorer fejl ved polling - vi vil ikke forstyrre UI'et
      // Session kan stadig være gyldig selvom polling fejler
    }
  }

  // Tjekker om quiz'en er startet baseret på status
  bool _isQuizStarted(String status) {
    return status.toLowerCase() == 'started' ||
        status.toLowerCase() == 'inprogress' ||
        status.toLowerCase() == 'in_progress';
  }

  // Henter leaderboard for sessionen
  Future<void> _fetchLeaderboard() async {
    if (_session == null || _isLoadingLeaderboard) return;

    setState(() {
      _isLoadingLeaderboard = true;
    });

    try {
      final leaderboard = await fetchLeaderboard(_session!.id);
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _isLoadingLeaderboard = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLeaderboard = false;
        });
      }
      // Ignorer fejl ved hentning af leaderboard
    }
  }

  // Starter quiz session
  Future<void> _startQuiz() async {
    if (_session == null || _session!.participantCount < 1) return;

    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    try {
      await startQuizSession(_session!.id);
      // Stop session polling når quiz'en starter
      _pollingTimer?.cancel();
      // Opdaterer session efter start for at få den nye status
      await _updateSession();
      // Henter leaderboard når quiz'en er startet
      if (_session != null && _isQuizStarted(_session!.status)) {
        await _fetchLeaderboard();
      }
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isStarting = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
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
                    _session!.participantCount == 1 ? 'deltager' : 'deltagere',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          // Vis kun "Start Quiz" knappen hvis quiz'en ikke er startet
          if (!_isQuizStarted(_session!.status)) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: (_session!.participantCount >= 1 && !_isStarting)
                  ? _startQuiz
                  : null,
              icon: _isStarting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isStarting ? 'Starter...' : 'Start Quiz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            if (_session!.participantCount < 1) ...[
              const SizedBox(height: 8),
              Text(
                'Vent på mindst én deltager',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ],
          // Vis leaderboard hvis quiz'en er startet
          if (_isQuizStarted(_session!.status)) ...[
            const SizedBox(height: 24),
            const Text(
              'Leaderboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLeaderboard(),
          ],
        ],
      ),
    );
  }

  // Bygger leaderboard widget
  Widget _buildLeaderboard() {
    if (_isLoadingLeaderboard) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      );
    }

    if (_leaderboard == null || _leaderboard!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Ingen deltagere endnu'),
      );
    }

    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _leaderboard!.length,
        itemBuilder: (context, index) {
          final entry = _leaderboard![index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                '${entry.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              entry.nickname,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '${entry.totalPoints} point',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
