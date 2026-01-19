import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session_dto.dart';
import '../models/participant_dto.dart';
import '../models/question_dto.dart';
import '../models/answer_submission_dto.dart';
import '../models/leaderboard_dto.dart';

class KahootApiService {
  static const String baseUrl = 'https://kahoot-api.mercantec.tech';

  // Get session by PIN
  Future<SessionDto> getSessionByPin(String pin) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/quizsession/pin/$pin'),
    );

    if (response.statusCode == 200) {
      return SessionDto.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('Session not found');
    } else {
      throw Exception('Failed to load session: ${response.statusCode}');
    }
  }

  // Join session
  Future<ParticipantDto> joinSession(String sessionPin, String nickname) async {
    final request = JoinSessionRequest(
      sessionPin: sessionPin,
      nickname: nickname,
    );

    final response = await http.post(
      Uri.parse('$baseUrl/api/quizsession/join'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ParticipantDto.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('Session not found');
    } else if (response.statusCode == 400) {
      throw Exception('Session has already started');
    } else if (response.statusCode == 409) {
      throw Exception('Nickname is already taken');
    } else {
      throw Exception('Failed to join session: ${response.statusCode}');
    }
  }

  // Get current question
  Future<QuestionDto?> getCurrentQuestion(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/participant/session/$sessionId/current-question'),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body != null) {
        return QuestionDto.fromJson(body as Map<String, dynamic>);
      }
      return null;
    } else if (response.statusCode == 404) {
      return null; // No question available yet
    } else {
      throw Exception('Failed to load question: ${response.statusCode}');
    }
  }

  // Submit answer
  Future<SubmitAnswerResponse> submitAnswer(
    int participantId,
    int questionId,
    int answerId,
    int responseTimeMs,
  ) async {
    final request = SubmitAnswerRequest(
      participantId: participantId,
      questionId: questionId,
      answerId: answerId,
      responseTimeMs: responseTimeMs,
    );

    final response = await http.post(
      Uri.parse('$baseUrl/api/participant/submit-answer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return SubmitAnswerResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to submit answer: ${response.statusCode}');
    }
  }

  // Get leaderboard
  Future<List<LeaderboardEntryDto>> getLeaderboard(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/participant/leaderboard/$sessionId'),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body
          .map((e) => LeaderboardEntryDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load leaderboard: ${response.statusCode}');
    }
  }
}
