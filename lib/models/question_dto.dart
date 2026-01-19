class QuestionDto {
  final int id;
  final String? text;
  final int timeLimitSeconds;
  final int points;
  final int orderIndex;
  final List<AnswerDto>? answers;

  QuestionDto({
    required this.id,
    this.text,
    required this.timeLimitSeconds,
    required this.points,
    required this.orderIndex,
    this.answers,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    return QuestionDto(
      id: json['id'] as int,
      text: json['text'] as String?,
      timeLimitSeconds: json['timeLimitSeconds'] as int,
      points: json['points'] as int,
      orderIndex: json['orderIndex'] as int,
      answers: json['answers'] != null
          ? (json['answers'] as List)
              .map((e) => AnswerDto.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class AnswerDto {
  final int id;
  final String? text;
  final bool isCorrect;
  final int orderIndex;

  AnswerDto({
    required this.id,
    this.text,
    required this.isCorrect,
    required this.orderIndex,
  });

  factory AnswerDto.fromJson(Map<String, dynamic> json) {
    return AnswerDto(
      id: json['id'] as int,
      text: json['text'] as String?,
      isCorrect: json['isCorrect'] as bool,
      orderIndex: json['orderIndex'] as int,
    );
  }
}
