class Participant {
  final int id;
  final String nickname;
  final int totalPoints;
  final DateTime joinedAt;
  final int quizSessionId;
  // Constructor for Participant class
  Participant({
    required this.id,
    required this.nickname,
    required this.totalPoints,
    required this.joinedAt,
    required this.quizSessionId,
  });

  // Opretter et Participant-objekt ud fra JSON-data modtaget fra API'et
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
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
