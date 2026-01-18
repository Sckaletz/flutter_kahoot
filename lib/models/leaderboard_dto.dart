class LeaderboardEntryDto {
  final int participantId;
  final String? nickname;
  final int totalPoints;
  final int rank;

  LeaderboardEntryDto({
    required this.participantId,
    this.nickname,
    required this.totalPoints,
    required this.rank,
  });

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryDto(
      participantId: json['participantId'] as int,
      nickname: json['nickname'] as String?,
      totalPoints: json['totalPoints'] as int,
      rank: json['rank'] as int,
    );
  }
}
