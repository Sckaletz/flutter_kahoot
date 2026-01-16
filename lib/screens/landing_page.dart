// Importerer Flutter Material Design komponenter
import 'package:flutter/material.dart';
// Importerer QuizListPage skærmen, så vi kan navigere til den
import 'quiz_list_page.dart';

// LandingPage er den første skærm, brugeren ser når appen starter
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold er den grundlæggende layout struktur for skærmen
    return Scaffold(
      // Body indeholder hovedindholdet på skærmen
      body: Center(
        // Column arrangerer widgets vertikalt (nedad)
        child: Column(
          // Centrerer indholdet vertikalt i kolonnen
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Titel tekst "Guldgruppen Kahoot"
            const Text(
              'Guldgruppen Kahoot',
              style: TextStyle(
                fontSize: 32, // Størrelse på teksten
                fontWeight: FontWeight.bold, // Fed tekst
                color: Color.fromARGB(255, 155, 120, 14), // Guld farve
              ),
            ),
            // Tomt rum på 48 pixels mellem titel og knap
            const SizedBox(height: 48),
            // Knap der navigerer til quiz listen
            ElevatedButton(
              // Hvad der sker når knappen trykkes
              onPressed: () {
                // Navigator.push navigerer til en ny skærm
                Navigator.push(
                  context,
                  // Opretter en ny route til QuizListPage
                  MaterialPageRoute(builder: (context) => const QuizListPage()),
                );
              },
              // Styling for knappen
              style: ElevatedButton.styleFrom(
                // Padding giver plads omkring teksten i knappen
                padding: const EdgeInsets.symmetric(
                  horizontal: 32, // 32 pixels på hver side
                  vertical: 16, // 16 pixels over og under
                ),
              ),
              // Teksten på knappen
              child: const Text('Mine quizzes', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
