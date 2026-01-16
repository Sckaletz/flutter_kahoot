import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';

class ApiService {
  // API Base URL
  static const String baseUrl = 'https://kahoot-api.mercantec.tech/api';

  // Henter alle tilgængelige quizzer
  static Future<List<Quiz>> getQuizzes() async {
    final response = await http.get(Uri.parse('$baseUrl/Quiz'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((q) => Quiz.fromJson(q)).toList();
    }
    throw Exception('Failed to load quizzes');
  }
}
