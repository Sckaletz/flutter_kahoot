class Answer {
  final int id;
  final String text;
  final bool isCorrect;
  final int orderIndex;

  Answer({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.orderIndex,
  });

  // Opretter en Answer instans fra JSON data
  factory Answer.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'text': String text,
        'isCorrect': bool isCorrect,
        'orderIndex': int orderIndex,
      } =>
        Answer(
          id: id,
          text: text,
          isCorrect: isCorrect,
          orderIndex: orderIndex,
        ),
      _ => throw const FormatException('Failed to load answer.'),
    };
  }
}

class Question {
  final int id;
  final String text;
  final int timeLimitSeconds;
  final int points;
  final int orderIndex;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.text,
    required this.timeLimitSeconds,
    required this.points,
    required this.orderIndex,
    required this.answers,
  });

  // Opretter en Question instans fra JSON data
  factory Question.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'text': String text,
        'timeLimitSeconds': int timeLimitSeconds,
        'points': int points,
        'orderIndex': int orderIndex,
      } =>
        Question(
          id: id,
          text: text,
          timeLimitSeconds: timeLimitSeconds,
          points: points,
          orderIndex: orderIndex,
          answers:
              (json['answers'] as List<dynamic>?)
                  ?.map((a) => Answer.fromJson(a as Map<String, dynamic>))
                  .toList() ??
              [],
        ),
      _ => throw const FormatException('Failed to load question.'),
    };
  }
}
