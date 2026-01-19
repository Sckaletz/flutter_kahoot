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
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pin: json['pin'] as String? ?? '',
      status: json['status'] as String? ?? '',
      questionCount: json['questionCount'] as int? ?? 0,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
