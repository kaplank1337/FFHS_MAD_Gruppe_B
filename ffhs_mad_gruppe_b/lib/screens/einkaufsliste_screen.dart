import 'package:flutter/material.dart';

class EinkaufslisteScreen extends StatelessWidget {
  final String name;

  const EinkaufslisteScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Name")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $name", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Später: Item hinzufügen
                },
                child: const Text("Hinzufügen"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
