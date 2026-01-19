import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import '../models/quiz_session.dart';

// API Base URL
const String baseUrl = 'https://kahoot-api.mercantec.tech/api';

// Henter alle tilgængelige quizzer
Future<List<Quiz>> fetchQuizzes() async {
  final response = await http.get(Uri.parse('$baseUrl/Quiz'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return (jsonDecode(response.body) as List<dynamic>)
        .map((q) => Quiz.fromJson(q as Map<String, dynamic>))
        .toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Kunne ikke indlæse quizzer');
  }
}

// Henter session via PIN
Future<QuizSession> fetchSessionByPin(String pin) async {
  final response = await http.get(Uri.parse('$baseUrl/QuizSession/pin/$pin'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return QuizSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Kunne ikke finde session med PIN: $pin');
  }
}
