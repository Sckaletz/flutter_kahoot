class QuizSession {
  final int id;
  final String sessionPin;
  final String status;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int currentQuestionOrderIndex;
  final int quizId;
  final String quizTitle;
  final int participantCount;

  QuizSession({
    required this.id,
    required this.sessionPin,
    required this.status,
    this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.currentQuestionOrderIndex,
    required this.quizId,
    required this.quizTitle,
    required this.participantCount,
  });

  // Opretter et QuizSession-objekt ud fra JSON-data modtaget fra API'et
  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'] ?? 0,
      sessionPin: json['sessionPin'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      currentQuestionOrderIndex: json['currentQuestionOrderIndex'] ?? 0,
      quizId: json['quizId'] ?? 0,
      quizTitle: json['quizTitle'] ?? '',
      participantCount: json['participantCount'] ?? 0,
    );
  }
}
