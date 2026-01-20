class Leaderboard {
  final int participantId;
  final String nickname;
  final int totalPoints;
  final int rank;

  // Constructor for Leaderboard class
  Leaderboard({
    required this.participantId,
    required this.nickname,
    required this.totalPoints,
    required this.rank,
  });

  // Opretter en Leaderboard instans fra JSON data
  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      participantId: json['participantId'] ?? 0,
      nickname: json['nickname'] ?? '',
      totalPoints: json['totalPoints'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}
