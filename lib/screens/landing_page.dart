// Importerer Flutter Material Design komponenter
import 'package:flutter/material.dart';
// Importerer QuizListPage skærmen, så vi kan navigere til den
import 'quiz_list_page.dart';
// Importerer ApiService, så vi kan hente session via PIN
import '../services/api_service.dart';

// LandingPage er den første skærm, brugeren ser når appen starter
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

// Privat state klasse, der håndterer logikken og tilstanden for LandingPage
class _LandingPageState extends State<LandingPage> {
  // TextEditingController til at håndtere PIN input feltet
  final TextEditingController _pinController = TextEditingController();
  // Boolean der angiver om data stadig indlæses
  bool _isLoading = false;
  // Besked der vises hvis der opstår en fejl
  String? _errorMessage;

  @override
  // Rydder op når widget'en bliver destrueret
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // Metode der henter session via PIN og håndterer fejl
  Future<void> _joinQuiz() async {
    final pin = _pinController.text.trim();

    // Validerer at PIN ikke er tom
    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Indtast venligst en PIN';
      });
      return;
    }

    // Opdaterer UI til at vise loading tilstand
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Henter session fra API'et via ApiService
      final session = await ApiService.getSessionByPin(pin);
      // TODO: Naviger til quiz session skærm når den er oprettet
      // For nu viser vi bare en success besked
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tilsluttet quiz: ${session.quizTitle}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Håndterer fejl hvis API kaldet fejler
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold er den grundlæggende layout struktur for skærmen
    return Scaffold(
      // Body indeholder hovedindholdet på skærmen
      body: Center(
        // Column arrangerer widgets vertikalt (nedad)
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
              // Tomt rum på 48 pixels mellem titel og input felt
              const SizedBox(height: 48),
              // PIN input felt
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  hintText: 'Indtast quiz PIN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              // Viser fejlbesked hvis der er en fejl
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              // Tomt rum på 24 pixels mellem input og knap
              const SizedBox(height: 24),
              // Knap der deltager i quiz
              ElevatedButton(
                // Hvad der sker når knappen trykkes
                onPressed: _isLoading ? null : _joinQuiz,
                // Styling for knappen
                style: ElevatedButton.styleFrom(
                  // Padding giver plads omkring teksten i knappen
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32, // 32 pixels på hver side
                    vertical: 16, // 16 pixels over og under
                  ),
                ),
                // Teksten på knappen eller loading indikator
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Deltag i quiz',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              // Tomt rum på 24 pixels mellem knapper
              const SizedBox(height: 24),
              // Knap der navigerer til quiz listen
              ElevatedButton(
                // Hvad der sker når knappen trykkes
                onPressed: () {
                  // Navigator.push navigerer til en ny skærm
                  Navigator.push(
                    context,
                    // Opretter en ny route til QuizListPage
                    MaterialPageRoute(
                      builder: (context) => const QuizListPage(),
                    ),
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
                child: const Text(
                  'Mine quizzes',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
