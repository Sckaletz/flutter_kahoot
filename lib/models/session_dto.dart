class SessionDto {
  final int id;
  final String? sessionPin;
  final String? status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? currentQuestionOrderIndex;
  final int quizId;
  final String? quizTitle;
  final int participantCount;

  SessionDto({
    required this.id,
    this.sessionPin,
    this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.currentQuestionOrderIndex,
    required this.quizId,
    this.quizTitle,
    required this.participantCount,
  });

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    return SessionDto(
      id: json['id'] as int,
      sessionPin: json['sessionPin'] as String?,
      status: json['status'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      currentQuestionOrderIndex: json['currentQuestionOrderIndex'] as int?,
      quizId: json['quizId'] as int,
      quizTitle: json['quizTitle'] as String?,
      participantCount: json['participantCount'] as int,
    );
  }
}
