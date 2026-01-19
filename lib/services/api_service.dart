import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import '../models/quiz_session.dart';
import '../models/participant.dart';
import '../models/leaderboard.dart';
import '../models/question.dart';

// API Basis URL
const String baseUrl = 'https://kahoot-api.mercantec.tech/api';

// HENTER ALL QUIZZES
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

// HENTER QUIZ VIA ID
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

// HENTER QUIZ SESSION VIA PIN
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

// OPRETTER EN NY QUIZ SESSION OG GENERERER EN PIN
Future<QuizSession> createPin(int quizId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/QuizSession'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{'quizId': quizId}),
    );

    // API'et returnerer 201 Created ved succes
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Hvis serveren returnerede en 200 OK eller 201 CREATED response,
      // så parse JSON'en.
      return QuizSession.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // Hvis serveren ikke returnerede en 200/201 response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke oprette PIN for quiz ID $quizId: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// JOIN SESSION - returnerer Participant (deltageren der joine'r)
Future<Participant> joinSession(String sessionPin, String nickname) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/QuizSession/join'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'sessionPin': sessionPin,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Hvis serveren returnerede en 200 OK eller 201 CREATED response,
      // så parse JSON'en.
      return Participant.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // Hvis serveren ikke returnerede en 200/201 response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke joine session med PIN $sessionPin: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// HENTER EN DELTAGER VIA PARTICIPANT-ID
Future<Participant> fetchParticipant(int participantId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/QuizSession/participants/$participantId'),
    );

    if (response.statusCode == 200) {
      // Hvis serveren returnerede en 200 OK response,
      // så parse JSON'en.
      return Participant.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke hente deltager med ID $participantId: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// STARTER EN QUIZ SESSION
Future<void> startQuizSession(int sessionId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/QuizSession/$sessionId/start'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Session er startet succesfuldt
      return;
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke starte session med ID $sessionId: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// HENTER LEADERBOARD
Future<List<Leaderboard>> fetchLeaderboard(int sessionId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/Participant/leaderboard/$sessionId'),
    );

    if (response.statusCode == 200) {
      // Hvis serveren returnerede en 200 OK response,
      // så parse JSON'en.
      return (jsonDecode(response.body) as List<dynamic>)
          .map((l) => Leaderboard.fromJson(l as Map<String, dynamic>))
          .toList();
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke hente leaderboard med ID $sessionId: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// HENTER NUVÆRENDE SPØRGSMÅL FOR EN SESSION
Future<Question> fetchCurrentQuestion(int sessionId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/Participant/session/$sessionId/current-question'),
    );

    if (response.statusCode == 200) {
      // Hvis serveren returnerede en 200 OK response,
      // så parse JSON'en.
      return Question.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke hente nuværende spørgsmål for session $sessionId: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// INDSENDER SVAR PÅ ET SPØRGSMÅL
Future<void> submitAnswer(
  int participantId,
  int questionId,
  int answerId,
  int responseTimeMs,
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Participant/submit-answer'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'participantId': participantId,
        'questionId': questionId,
        'answerId': answerId,
        'responseTimeMs': responseTimeMs,
      }),
    );

    if (response.statusCode == 200) {
      // Svar er indsendt succesfuldt
      return;
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception('Kunne ikke indsende svar: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}

// AFSLUTTER EN QUIZ SESSION
Future<void> completeQuizSession(int sessionId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/QuizSession/$sessionId/complete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Session er afsluttet succesfuldt
      return;
    } else {
      // Hvis serveren ikke returnerede en 200 OK response,
      // så kast en exception.
      throw Exception(
        'Kunne ikke afslutte session med ID $sessionId: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('Fejl ved API kald: $e');
  }
}
