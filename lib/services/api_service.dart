import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import '../models/quiz_session.dart';

class ApiService {
  // API Base URL
  static const String baseUrl = 'https://kahoot-api.mercantec.tech/api';

  // Henter alle tilgængelige quizzer
  Future<List<Quiz>> getQuizzes() async {
    final response = await http.get(Uri.parse('$baseUrl/Quiz'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((q) => Quiz.fromJson(q)).toList();
    }
    throw Exception('Kunne ikke indlæse quizzer');
  }

  // Henter session via PIN
  Future<QuizSession> getSessionByPin(String pin) async {
    final response = await http.get(Uri.parse('$baseUrl/QuizSession/pin/$pin'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return QuizSession.fromJson(data);
    }
    throw Exception('Kunne ikke finde session med PIN: $pin');
  }
}
