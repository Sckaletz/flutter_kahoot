import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // den officielle dybe Kahoot-lilla farve (Hex-kode)
      backgroundColor: const Color(0xFF46178F),

      body: SafeArea(
        child: Padding(
          // giver lidt luft i siderne (20 pixels), så knapperne ikke rører kanten
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centrer alt lodret
            children: [
              // --- DEL 1: LOGO OG TEKST ---
              //en skygge under teksten for en 3D-effekt
              const Text(
                'Kahoot!',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900, // Ekstra fed skrift
                  color: Colors.white,
                  letterSpacing: 2, // Lidt luft mellem bogstaverne
                ),
              ),

              const SizedBox(height: 10), // Lille afstand

              const Text(
                'Ready to play?',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white70, // Hvid, men lidt gennemsigtig
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 80), // Stor afstand ned til knapperne
              // --- DEL 2: "JOIN" KNAPPEN ---
              SizedBox(
                width: double.infinity, // Knappen skal fylde hele bredden
                height: 60, // Knappen skal være høj og nem at ramme
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Hvid baggrund
                    foregroundColor: Colors.black, // Sort tekst
                    elevation: 5, // Skygge under knappen
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Let afrundede hjørner
                    ),
                  ),
                  onPressed: () {
                    // Denne kode sender til "Enter PIN" siden
                    Navigator.pushNamed(context, '/');
                  },
                  child: const Text(
                    'Enter PIN',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20), // Luft mellem knapperne
              // --- DEL 3: "CREATE" KNAPPEN ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF382396,
                    ), // En lidt lysere lilla
                    foregroundColor: Colors.white, // Hvid tekst
                    elevation:
                        0, // Ingen skygge (gør den mindre vigtig at se på)
                    side: const BorderSide(
                      color: Colors.white30,
                      width: 2,
                    ), // En kant
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // ikke lavet denne side endnu
                  },
                  child: const Text(
                    'Create Game',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // En lille tekst i bunden
              const SizedBox(height: 40),
              const Text(
                'Already have an account? Log in',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
