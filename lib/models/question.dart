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
    return Answer(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      orderIndex: json['orderIndex'] ?? 0,
    );
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
    return Question(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      timeLimitSeconds: json['timeLimitSeconds'] ?? 0,
      points: json['points'] ?? 0,
      orderIndex: json['orderIndex'] ?? 0,
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map((a) => Answer.fromJson(a))
              .toList() ??
          [],
    );
  }
}
