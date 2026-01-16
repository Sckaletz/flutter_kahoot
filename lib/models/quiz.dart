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
    return Quiz(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pin: json['pin'] ?? '',
      status: json['status'] ?? '',
      questionCount: json['questionCount'] ?? 0,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
    );
  }
}
