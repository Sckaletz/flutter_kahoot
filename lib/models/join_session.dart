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

  // Opretter en JoinSession instans fra JSON data modtaget fra API'et
  factory JoinSession.fromJson(Map<String, dynamic> json) {
    return JoinSession(
      id: json['id'] as int? ?? 0,
      nickname: json['nickname'] as String? ?? '',
      totalPoints: json['totalPoints'] as int? ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
      quizSessionId: json['quizSessionId'] as int? ?? 0,
    );
  }
}
