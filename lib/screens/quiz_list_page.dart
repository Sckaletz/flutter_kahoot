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
  // Future der indeholder quizzerne - bruges til FutureBuilder
  late Future<List<Quiz>> _futureQuizzes;

  @override
  // initState kaldes når widget'en først oprettes
  void initState() {
    super.initState();
    // Initialiserer Future med quizzer fra API'et
    _futureQuizzes = ApiService.getQuizzes();
  }

  // Metode der genindlæser quizzerne
  void _refreshQuizzes() {
    setState(() {
      // Opretter en ny Future, hvilket trigger FutureBuilder til at genindlæse
      _futureQuizzes = ApiService.getQuizzes();
    });
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
      // Body indeholder hovedindholdet - bruger FutureBuilder til at håndtere async data
      body: FutureBuilder<List<Quiz>>(
        // Future der skal håndteres
        future: _futureQuizzes,
        // Builder funktion der bygger UI baseret på Future's tilstand
        builder: (context, snapshot) {
          // Hvis data er blevet hentet succesfuldt
          if (snapshot.hasData) {
            final quizzes = snapshot.data!;

            // Hvis der ikke er nogen quizzer, vis besked
            if (quizzes.isEmpty) {
              return const Center(child: Text('Ingen quizzer fundet'));
            }

            // Hvis alt er okay, vis listen af quizzer
            return ListView.builder(
              // Antal items i listen
              itemCount: quizzes.length,
              // Builder funktion der opretter hvert item i listen
              itemBuilder: (context, index) {
                // Henter den aktuelle quiz
                final quiz = quizzes[index];
                return Card(
                  // Margin omkring kortet
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('${quiz.questionCount} spørgsmål'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          // Hvis der er opstået en fejl
          else if (snapshot.hasError) {
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
                      '${snapshot.error}',
                      textAlign: TextAlign.center, // Centrerer teksten
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Knap til at prøve igen
                  ElevatedButton.icon(
                    onPressed: _refreshQuizzes, // Prøver at hente quizzer igen
                    icon: const Icon(Icons.refresh),
                    label: const Text('Prøv igen'),
                  ),
                ],
              ),
            );
          }

          // Loading tilstand - vises mens data indlæses
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
