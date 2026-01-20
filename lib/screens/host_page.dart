import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quiz.dart';
import '../models/quiz_session.dart';
import '../models/leaderboard.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import 'leadboard_page.dart';

// HostPage viser en PIN til den valgte quiz og starter en ny session
class HostPage extends StatefulWidget {
  final Quiz quiz; // Quiz objekt der skal hostes

  const HostPage({super.key, required this.quiz});

  @override
  State<HostPage> createState() => _HostPageState(); // Opretter state objektet, der håndterer den faktiske tilstand
}

class _HostPageState extends State<HostPage> {
  QuizSession? _session; // QuizSession objekt der skal hostes
  bool _isLoading = true;
  bool _isStarting = false;
  String? _errorMessage;
  Timer? _pollingTimer;
  Timer? _questionPollingTimer;
  Timer? _countdownTimer;
  List<Leaderboard>? _leaderboard;
  bool _isLoadingLeaderboard = false;
  Question? _currentQuestion;
  int _timeRemaining = 0;

  @override
  void initState() {
    super.initState();
    // Opretter automatisk en session (og PIN) når man går ind på siden
    _createPin();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _questionPollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Opretter en ny session for den valgte quiz og genererer PIN
  Future<void> _createPin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await createPin(widget.quiz.id);
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

  // Starter polling for at hente nuværende spørgsmål og opdatere leaderboard
  void _startQuestionPolling() {
    _questionPollingTimer?.cancel();
    _questionPollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_session != null && _isQuizStarted(_session!.status)) {
        _fetchCurrentQuestion();
        _fetchLeaderboard(); // Opdater leaderboard løbende
      } else {
        timer.cancel();
      }
    });
  }

  // Henter nuværende spørgsmål
  Future<void> _fetchCurrentQuestion() async {
    if (_session == null) return;

    try {
      final question = await fetchCurrentQuestion(_session!.id);
      if (mounted) {
        // Hvis det er et nyt spørgsmål (forskelligt ID eller orderIndex)
        if (_currentQuestion == null ||
            _currentQuestion!.id != question.id ||
            _currentQuestion!.orderIndex != question.orderIndex) {
          setState(() {
            _currentQuestion = question;
            _timeRemaining = question.timeLimitSeconds;
          });
          _startCountdown();
        }
      }
    } catch (e) {
      // Hvis der ikke er flere spørgsmål, kan det betyde quiz'en er færdig
      // Tjek om quiz'en er færdig og naviger til leaderboard
      await _checkAndCompleteQuiz();
    }
  }

  // Tjekker om quiz'en er færdig og afslutter den
  Future<void> _checkAndCompleteQuiz() async {
    if (_session == null) return;

    try {
      // Opdater session for at tjekke status
      final updatedSession = await fetchSessionByPin(_session!.sessionPin);
      if (mounted) {
        // Tjek om quiz'en er færdig
        if (_isQuizCompleted(updatedSession)) {
          // Stop alle timers
          _questionPollingTimer?.cancel();
          _countdownTimer?.cancel();

          // Naviger til leaderboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LeaderboardPage(
                sessionId: updatedSession.id,
                quizTitle: updatedSession.quizTitle,
              ),
            ),
          );
        } else if (!_isQuizStarted(updatedSession.status)) {
          // Hvis quiz'en ikke er startet længere, kan det betyde den er færdig
          // Prøv at afslutte den
          try {
            await completeQuizSession(_session!.id);
            // Opdater session igen efter afslutning
            final finalSession = await fetchSessionByPin(_session!.sessionPin);
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardPage(
                    sessionId: finalSession.id,
                    quizTitle: finalSession.quizTitle,
                  ),
                ),
              );
            }
          } catch (e) {
            // Hvis afslutning fejler, naviger alligevel til leaderboard
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardPage(
                    sessionId: updatedSession.id,
                    quizTitle: updatedSession.quizTitle,
                  ),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      // Hvis der opstår en fejl, prøv alligevel at navigere til leaderboard
      if (mounted && _session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LeaderboardPage(
              sessionId: _session!.id,
              quizTitle: _session!.quizTitle,
            ),
          ),
        );
      }
    }
  }

  // Tjekker om quiz'en er færdig
  bool _isQuizCompleted(QuizSession session) {
    return session.status.toLowerCase() == 'completed' ||
        session.status.toLowerCase() == 'finished' ||
        session.completedAt != null;
  }

  // Starter nedtælling for spørgsmålet
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            timer.cancel();
          }
        });
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
        // Tjek om quiz'en er færdig
        if (_isQuizCompleted(updatedSession)) {
          _pollingTimer?.cancel();
          _questionPollingTimer?.cancel();
          _countdownTimer?.cancel();

          // Naviger til leaderboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LeaderboardPage(
                sessionId: updatedSession.id,
                quizTitle: updatedSession.quizTitle,
              ),
            ),
          );
          return;
        }

        final wasStarted = _isQuizStarted(_session!.status);
        final isNowStarted = _isQuizStarted(updatedSession.status);

        setState(() {
          _session = updatedSession;
        });

        // Hvis quiz'en lige er startet, stop session polling og start question polling
        if (!wasStarted && isNowStarted) {
          _pollingTimer?.cancel();
          _fetchLeaderboard();
          _startQuestionPolling();
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
      // Henter leaderboard når quiz'en er startet og starter question polling
      if (_session != null && _isQuizStarted(_session!.status)) {
        await _fetchLeaderboard();
        _startQuestionPolling();
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
            onPressed: _createPin,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _session!.sessionPin,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _session!.sessionPin));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN kopieret til udklipsholder'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                tooltip: 'Kopiér PIN',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
              ),
            ],
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
          // Vis spørgsmål, timer og leaderboard hvis quiz'en er startet
          if (_isQuizStarted(_session!.status)) ...[
            const SizedBox(height: 24),
            _buildQuestionSection(),
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

  // Bygger spørgsmål sektion
  Widget _buildQuestionSection() {
    if (_currentQuestion == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Venter på spørgsmål...'),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Timer
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _timeRemaining <= 5
                  ? Colors.red
                  : _timeRemaining <= 10
                  ? Colors.orange
                  : Colors.green,
            ),
            child: Center(
              child: Text(
                '$_timeRemaining',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Spørgsmål
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spørgsmål ${_currentQuestion!.orderIndex}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentQuestion!.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentQuestion!.points} point',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Svar muligheder
        ..._currentQuestion!.answers.map((answer) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: answer.isCorrect
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    if (answer.isCorrect) ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        answer.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: answer.isCorrect
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: answer.isCorrect ? Colors.green : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
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

    // Byg selv rækkerne i stedet for en indlejret ListView
    // for at undgå små RenderFlex-overflows i kortet.
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _leaderboard!.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${entry.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.nickname,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.totalPoints} point',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
