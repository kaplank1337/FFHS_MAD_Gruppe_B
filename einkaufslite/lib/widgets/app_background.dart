import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF236EF8),   // Sattes Blau oben
            Color(0xFF6AA7FF),   // Helles Blau in der Mitte
            Colors.white,        // Weiß weiter unten
          ],
          stops: [0.0, 0.8, 1.0], // Übergang erst bei 40 % starten
        ),
      ),
      child: child,
    );
  }
}
