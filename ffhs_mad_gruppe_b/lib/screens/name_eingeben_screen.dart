import 'package:flutter/material.dart';
import '../storage/list_storage.dart';

class NameEingebenScreen extends StatefulWidget {
  const NameEingebenScreen({super.key});

  @override
  State<NameEingebenScreen> createState() => _NameEingebenScreenState();
}

class _NameEingebenScreenState extends State<NameEingebenScreen> {
  final TextEditingController _controller = TextEditingController();

  void _speichernUndZurueck() async {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      await ListStorage.speichern(name);
      if (!context.mounted) return;
      Navigator.pop(context, true); // zurück zur Startseite
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: const Text("Name")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speichernUndZurueck,
              child: const Text("Speichern"),
            ),
          ],
        ),
      ),
    );
  }
}
