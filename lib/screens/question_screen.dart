import 'dart:async';
import 'package:flutter/material.dart';
import '../services/kahoot_api_service.dart';
import '../models/question_dto.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _apiService = KahootApiService();
  Timer? _pollTimer;
  Timer? _questionTimer;
  QuestionDto? _currentQuestion;
  int _timeRemaining = 0;
  int? _selectedAnswerId;
  bool _answerSubmitted = false;
  DateTime? _questionStartTime;
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
    _loadQuestion();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _checkForNextQuestion();
    });
  }

  Future<void> _loadQuestion() async {
    try {
      final question = await _apiService.getCurrentQuestion(_sessionId);
      if (question != null && mounted) {
        setState(() {
          _currentQuestion = question;
          _timeRemaining = question.timeLimitSeconds;
          _selectedAnswerId = null;
          _answerSubmitted = false;
          _questionStartTime = DateTime.now();
        });
        _startQuestionTimer();
      } else if (question == null && _currentQuestion != null && mounted) {
        // Quiz might be completed, check leaderboard
        _pollTimer?.cancel();
        _questionTimer?.cancel();
        Navigator.pushReplacementNamed(
          context,
          '/leaderboard',
          arguments: {
            'sessionId': _sessionId,
            'participantId': _participantId,
            'nickname': _nickname,
          },
        );
      }
    } catch (e) {
      debugPrint('Error loading question: $e');
    }
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
        if (_timeRemaining == 0 && !_answerSubmitted) {
          _submitAnswer(_selectedAnswerId ?? -1);
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkForNextQuestion() async {
    if (_answerSubmitted) {
      // Check if there's a new question
      final question = await _apiService.getCurrentQuestion(_sessionId);
      if (question != null && 
          _currentQuestion != null && 
          question.id != _currentQuestion!.id && 
          mounted) {
        _loadQuestion();
      } else if (question == null && mounted) {
        // Quiz completed
        _pollTimer?.cancel();
        _questionTimer?.cancel();
        Navigator.pushReplacementNamed(
          context,
          '/leaderboard',
          arguments: {
            'sessionId': _sessionId,
            'participantId': _participantId,
            'nickname': _nickname,
          },
        );
      }
    }
  }

  Future<void> _submitAnswer(int answerId) async {
    if (_answerSubmitted || _currentQuestion == null || answerId == -1) return;

    setState(() {
      _answerSubmitted = true;
    });

    _questionTimer?.cancel();

    final responseTime = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inMilliseconds
        : _currentQuestion!.timeLimitSeconds * 1000;

    try {
      await _apiService.submitAnswer(
        _participantId,
        _currentQuestion!.id,
        answerId,
        responseTime,
      );
    } catch (e) {
      debugPrint('Error submitting answer: $e');
    }
  }

  Color _getAnswerColor(int answerId) {
    if (_selectedAnswerId != answerId) {
      return Colors.white;
    }
    return const Color(0xFFFFB800); // Kahoot yellow
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestion == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF7B2CBF),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final answers = _currentQuestion!.answers ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF7B2CBF),
      body: SafeArea(
        child: Column(
          children: [
            // Timer bar
            Container(
              height: 8,
              color: const Color(0xFFFFB800),
              child: FractionallySizedBox(
                widthFactor: _timeRemaining / _currentQuestion!.timeLimitSeconds,
                alignment: Alignment.centerLeft,
                child: Container(color: Colors.white),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Question text
                    Text(
                      _currentQuestion!.text ?? '',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Answers
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: answers.length,
                        itemBuilder: (context, index) {
                          final answer = answers[index];
                          final isSelected = _selectedAnswerId == answer.id;
                          
                          return GestureDetector(
                            onTap: _answerSubmitted
                                ? null
                                : () {
                                    setState(() {
                                      _selectedAnswerId = answer.id;
                                    });
                                    _submitAnswer(answer.id);
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getAnswerColor(answer.id),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  answer.text ?? '',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? const Color(0xFF7B2CBF)
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_answerSubmitted)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Text(
                          'Answer submitted! Waiting for next question...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
