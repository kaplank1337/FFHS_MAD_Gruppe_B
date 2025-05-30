import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6D5DFB),
            Color(0xFF46A0FC), 
            Color(0xFF23D2D0), 
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -30,
            child: _circle(150, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            top: 100,
            right: -40,
            child: _circle(100, Colors.white.withOpacity(0.07)),
          ),
          Positioned(
            bottom: -40,
            left: 30,
            child: _circle(120, Colors.white.withOpacity(0.04)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
