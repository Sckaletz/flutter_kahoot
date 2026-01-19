class ParticipantDto {
  final int id;
  final String? nickname;
  final int totalPoints;
  final DateTime joinedAt;
  final int quizSessionId;

  ParticipantDto({
    required this.id,
    this.nickname,
    required this.totalPoints,
    required this.joinedAt,
    required this.quizSessionId,
  });

  factory ParticipantDto.fromJson(Map<String, dynamic> json) {
    return ParticipantDto(
      id: json['id'] as int,
      nickname: json['nickname'] as String?,
      totalPoints: json['totalPoints'] as int,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      quizSessionId: json['quizSessionId'] as int,
    );
  }
}

class JoinSessionRequest {
  final String sessionPin;
  final String nickname;

  JoinSessionRequest({
    required this.sessionPin,
    required this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionPin': sessionPin,
      'nickname': nickname,
    };
  }
}
