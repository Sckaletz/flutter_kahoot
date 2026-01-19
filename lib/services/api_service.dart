import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import '../models/quiz_session.dart';

// API Basis URL
const String baseUrl = 'https://kahoot-api.mercantec.tech/api';

// Henter alle tilgængelige quizzer
Future<List<Quiz>> fetchQuizzes() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/Quiz'));

    if (response.statusCode == 200) {
      // Hvis serveren returnerede en 200 OK response,
      // så parse JSON'en.
      return (jsonDecode(response.body) as List<dynamic>)
          .map((q) => Quiz.fromJson(q as Map<String, dynamic>))
          .toList();
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception('Kunne ikke indlæse quizzer: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// Henter en specifik quiz med alle spørgsmål og svar via ID
Future<Quiz> fetchQuizById(int id) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/Quiz/$id'));

    if (response.statusCode == 200) {
      // Hvis serveren returnerede en 200 OK response,
      // så parse JSON'en.
      return Quiz.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke indlæse quiz med ID $id: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// Henter session via PIN
Future<QuizSession> fetchSessionByPin(String pin) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/QuizSession/pin/$pin'));

    if (response.statusCode == 200) {
      // Hvis serveren returnerede en 200 OK response,
      // så parse JSON'en.
      return QuizSession.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke finde session med PIN: $pin: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}
