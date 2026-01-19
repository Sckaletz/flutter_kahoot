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
      id: json['id'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      orderIndex: json['orderIndex'] as int? ?? 0,
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
      id: json['id'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      orderIndex: json['orderIndex'] as int? ?? 0,
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map((a) => Answer.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
