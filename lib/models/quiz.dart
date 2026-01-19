import 'question.dart';

class Quiz {
  final int id;
  final String title;
  final String description;
  final String pin;
  final String status;
  final int questionCount;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.pin,
    required this.status,
    required this.questionCount,
    this.questions =
        const [], // default tom liste hvis ingen spørgsmål er givet
  });

  // Opretter en Quiz instans fra JSON data modtaget fra API'et
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'title': String title,
        'description': String description,
        'pin': String pin,
        'status': String status,
        'questionCount': int questionCount,
      } =>
        Quiz(
          id: id,
          title: title,
          description: description,
          pin: pin,
          status: status,
          questionCount: questionCount,
          questions:
              (json['questions'] as List<dynamic>?)
                  ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
                  .toList() ??
              [],
        ),
      _ => throw const FormatException('Failed to load quiz.'),
    };
  }
}
