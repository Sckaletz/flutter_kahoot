import 'dart:async';
import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../models/question.dart';
import '../models/quiz_session.dart';
import '../services/api_service.dart';
import 'leadboard_page.dart';

// GameScreenPage viser spørgsmål og giver mulighed for at svare
class GameScreenPage extends StatefulWidget {
  final Participant participant;
  final String sessionPin;

  const GameScreenPage({
    super.key,
    required this.participant,
    required this.sessionPin,
  });

  @override
  State<GameScreenPage> createState() => _GameScreenPageState();
}

class _GameScreenPageState extends State<GameScreenPage> {
  QuizSession? _session; // Session info
  Question? _currentQuestion;
  bool _isLoading = true;
  bool _isQuizStarted = false;
  bool _hasAnswered = false;
  int? _selectedAnswerId;
  bool? _isAnswerCorrect;
  int _timeRemaining = 0;
  Timer? _countdownTimer;
  Timer? _sessionPollingTimer; // Polling til at hente session info
  int _totalPoints = 0;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _totalPoints = widget.participant.totalPoints;
    _checkSessionStatus(); // Tjekker session status for at se om quiz er startet
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _sessionPollingTimer?.cancel();
    super.dispose();
  }

  // Tjekker session status for at se om quiz er startet
  Future<void> _checkSessionStatus() async {
    try {
      final session = await fetchSessionByPin(widget.sessionPin);
      if (mounted) {
        // Tjek om quiz er færdig
        if (_isQuizCompleted(session)) {
          // Naviger til leaderboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LeaderboardPage(
                sessionId: session.id,
                quizTitle: session.quizTitle,
              ),
            ),
          );
          return;
        }

        setState(() {
          _session = session;
          _isQuizStarted = _isSessionStarted(session.status);
          _isLoading = false;
        });

        if (_isQuizStarted) {
          _startQuestionPolling();
        } else {
          _startSessionPolling();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Tjekker om session er startet
  bool _isSessionStarted(String status) {
    return status.toLowerCase() == 'started' ||
        status.toLowerCase() == 'inprogress';
  }

  // Tjekker om quiz er færdig
  bool _isQuizCompleted(QuizSession session) {
    return session.status.toLowerCase() == 'completed' ||
        session.status.toLowerCase() == 'finished' ||
        session.completedAt != null;
  }

  // Starter polling for at tjekke om quiz er startet
  void _startSessionPolling() {
    _sessionPollingTimer?.cancel();
    _sessionPollingTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (!_isQuizStarted) {
        _checkSessionStatus();
      } else {
        timer.cancel();
        _startQuestionPolling();
      }
    });
  }

  // Starter polling for at hente nye spørgsmål
  void _startQuestionPolling() {
    _sessionPollingTimer?.cancel();
    _sessionPollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isQuizStarted) {
        _checkSessionStatus(); // Tjek også om quiz er færdig
        _fetchCurrentQuestion();
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
            _hasAnswered = false;
            _selectedAnswerId = null;
            _isAnswerCorrect = null;
            _questionStartTime = DateTime.now();
          });
          _startCountdown();
        }
      }
    } catch (e) {
      // Hvis der ikke er flere spørgsmål, tjek om quiz er færdig
      if (mounted && _session != null) {
        _checkSessionStatus();
      }
    }
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
            // Tiden er udløbet - automatisk submit hvis ikke svaret
            if (!_hasAnswered && _selectedAnswerId != null) {
              _submitAnswer(_selectedAnswerId!);
            }
          }
        });
      }
    });
  }

  // Indsender svar
  Future<void> _submitAnswer(int answerId) async {
    if (_hasAnswered ||
        _currentQuestion == null ||
        _questionStartTime == null) {
      return;
    }

    _countdownTimer?.cancel();

    final responseTimeMs = DateTime.now()
        .difference(_questionStartTime!)
        .inMilliseconds;

    // Gem point før indsendelse for at kunne bestemme om svaret var korrekt
    final pointsBefore = _totalPoints;

    try {
      await submitAnswer(
        widget.participant.id,
        _currentQuestion!.id,
        answerId,
        responseTimeMs,
      );

      // Opdater point ved at hente participant igen
      final updatedParticipant = await fetchParticipant(widget.participant.id);
      if (mounted) {
        // Bestem om svaret var korrekt baseret på om point er steget
        final pointsAfter = updatedParticipant.totalPoints;
        final isCorrect = pointsAfter > pointsBefore;

        setState(() {
          _hasAnswered = true;
          _selectedAnswerId = answerId;
          _isAnswerCorrect = isCorrect;
          _totalPoints = pointsAfter;
        });
      }
    } catch (e) {
      // Håndter fejl
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved indsendelse af svar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.participant.nickname}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isQuizStarted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Venter på at host starter quiz',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Point: $_totalPoints', style: const TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    if (_currentQuestion == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Venter på spørgsmål...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Point display
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Point:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_totalPoints',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Nedtælling timer
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
          const SizedBox(height: 24),
          // Svar muligheder
          ..._currentQuestion!.answers.map((answer) {
            final isSelected = _selectedAnswerId == answer.id;
            final isDisabled = _hasAnswered;
            final isCorrectAnswer = answer.isCorrect;

            // Bestem farve baseret på status
            Color? backgroundColor;
            Color? foregroundColor;
            IconData? icon;

            if (_hasAnswered) {
              if (isCorrectAnswer) {
                // Korrekt svar - altid grøn
                backgroundColor = Colors.green;
                foregroundColor = Colors.white;
                icon = Icons.check_circle;
              } else if (isSelected) {
                // Forkert valgt svar - rød
                backgroundColor = Colors.red;
                foregroundColor = Colors.white;
                icon = Icons.cancel;
              } else {
                // Ikke valgt svar - grå
                backgroundColor = Colors.grey[300];
                foregroundColor = Colors.grey[700];
              }
            } else if (isSelected) {
              // Valgt men ikke sendt endnu
              backgroundColor = Theme.of(context).colorScheme.primary;
              foregroundColor = Colors.white;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () {
                        _submitAnswer(answer.id);
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        answer.text,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_hasAnswered) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAnswerCorrect == true
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isAnswerCorrect == true ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isAnswerCorrect == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: _isAnswerCorrect == true ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAnswerCorrect == true ? 'Korrekt!' : 'Forkert svar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isAnswerCorrect == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Vent på næste spørgsmål...',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
