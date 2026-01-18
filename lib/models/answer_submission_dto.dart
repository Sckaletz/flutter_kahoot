class SubmitAnswerRequest {
  final int participantId;
  final int questionId;
  final int answerId;
  final int responseTimeMs;

  SubmitAnswerRequest({
    required this.participantId,
    required this.questionId,
    required this.answerId,
    required this.responseTimeMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'questionId': questionId,
      'answerId': answerId,
      'responseTimeMs': responseTimeMs,
    };
  }
}

class SubmitAnswerResponse {
  final String message;
  final int participantAnswerId;
  final int pointsEarned;
  final bool isCorrect;
  final int totalPoints;

  SubmitAnswerResponse({
    required this.message,
    required this.participantAnswerId,
    required this.pointsEarned,
    required this.isCorrect,
    required this.totalPoints,
  });

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) {
    return SubmitAnswerResponse(
      message: json['message'] as String,
      participantAnswerId: json['participantAnswerId'] as int,
      pointsEarned: json['pointsEarned'] as int,
      isCorrect: json['isCorrect'] as bool,
      totalPoints: json['totalPoints'] as int,
    );
  }
}
