// Importerer Flutter Material Design komponenter
import 'package:flutter/material.dart';
// Importerer Quiz modellen, så vi kan bruge Quiz objekter
import '../models/quiz.dart';
// Importerer ApiService, så vi kan hente quizzer fra API'et
import '../services/api_service.dart';

// QuizListPage er en StatefulWidget, fordi den skal kunne opdatere sin tilstand
class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  // Opretter state objektet, der håndterer den faktiske tilstand
  State<QuizListPage> createState() => _QuizListPageState();
}

// Privat state klasse, der håndterer logikken og tilstanden for QuizListPage
class _QuizListPageState extends State<QuizListPage> {
  // Liste over quizzer, der skal vises
  List<Quiz> _quizzes = [];
  // Boolean der angiver om data stadig indlæses
  bool _isLoading = true;
  // Besked der vises hvis der opstår en fejl
  String? _errorMessage;

  @override
  // initState kaldes når widget'en først oprettes
  void initState() {
    super.initState();
    // Henter quizzer med det samme når skærmen åbnes
    _fetchQuizzes();
  }

  // Asynkron metode der henter quizzer fra API'et
  Future<void> _fetchQuizzes() async {
    // Opdaterer UI til at vise loading tilstand
    setState(() {
      _isLoading = true; // Sætter loading til true
      _errorMessage = null; // Nulstiller eventuelle fejlbeskeder
    });

    try {
      // Henter quizzer fra API'et via ApiService
      final quizzes = await ApiService.getQuizzes();
      // Opdaterer UI med de hentede quizzer
      setState(() {
        _quizzes = quizzes; // Gemmer quizzerne
        _isLoading = false; // Stopper loading indikator
      });
    } catch (e) {
      // Håndterer fejl hvis API kaldet fejler
      setState(() {
        _errorMessage = e.toString(); // Gemmer fejlbeskeden
        _isLoading = false; // Stopper loading indikator
      });
    }
  }

  @override
  // build metode der bygger UI'et
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar er top baren på skærmen
      appBar: AppBar(
        // Baggrundsfarve fra temaet
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Titel i AppBar
        title: const Text('Kahoot Quizzes'),
      ),
      // Body indeholder hovedindholdet
      body: _buildBody(),
    );
  }

  // Hjælpemetode der bygger body indholdet baseret på tilstanden
  Widget _buildBody() {
    // Hvis data stadig indlæses, vis loading indikator
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hvis der er en fejl, vis fejlbesked
    if (_errorMessage != null) {
      return Center(
        child: Column(
          // Centrerer indholdet vertikalt
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rød fejl ikon
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            // Fejlbesked overskrift
            Text(
              'Fejl ved indlæsning af quizzer',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            // Detaljeret fejlbesked
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center, // Centrerer teksten
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            // Knap til at prøve igen
            ElevatedButton.icon(
              onPressed: _fetchQuizzes, // Prøver at hente quizzer igen
              icon: const Icon(Icons.refresh),
              label: const Text('Prøv igen'),
            ),
          ],
        ),
      );
    }

    // Hvis der ikke er nogen quizzer, vis besked
    if (_quizzes.isEmpty) {
      return const Center(child: Text('Ingen quizzer fundet'));
    }

    // Hvis alt er okay, vis listen af quizzer
    return RefreshIndicator(
      // Tillader brugeren at trække ned for at opdatere listen
      onRefresh: _fetchQuizzes,
      child: ListView.builder(
        // Antal items i listen
        itemCount: _quizzes.length,
        // Builder funktion der opretter hvert item i listen
        itemBuilder: (context, index) {
          // Henter den aktuelle quiz
          final quiz = _quizzes[index];
          return Card(
            // Margin omkring kortet
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // Padding inde i ListTile
              contentPadding: const EdgeInsets.all(16),
              // Quiz titel
              title: Text(
                quiz.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Fed tekst
                  fontSize: 18,
                ),
              ),
              // Quiz beskrivelse og spørgsmål antal
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quiz beskrivelse (kun hvis den ikke er tom)
                  if (quiz.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(quiz.description),
                    ),
                  // Antal spørgsmål
                  Padding(
                    padding: const EdgeInsets.only(top: 4), //
                    child: Text('${quiz.questionCount} spørgsmål'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
