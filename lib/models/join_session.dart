class JoinSession {
  final int id;
  final String nickname;
  final int totalPoints;
  final DateTime joinedAt;
  final int quizSessionId;

  JoinSession({
    required this.id,
    required this.nickname,
    required this.totalPoints,
    required this.joinedAt,
    required this.quizSessionId,
  });

  // Opretter en JoinSession instans fra JSON data
  factory JoinSession.fromJson(Map<String, dynamic> json) {
    return JoinSession(
      id: json['id'] ?? 0,
      nickname: json['nickname'] ?? '',
      totalPoints: json['totalPoints'] ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      quizSessionId: json['quizSessionId'] ?? 0,
    );
  }
}
