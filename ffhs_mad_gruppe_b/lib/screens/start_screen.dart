import 'package:flutter/material.dart';
import 'name_eingeben_screen.dart';
import '../storage/list_storage.dart';

class EinkaufslisteStartScreen extends StatefulWidget {
  const EinkaufslisteStartScreen({super.key});

  @override
  State<EinkaufslisteStartScreen> createState() => _EinkaufslisteStartScreenState();
}

class _EinkaufslisteStartScreenState extends State<EinkaufslisteStartScreen> {
  List<String> _listen = [];

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    final daten = await ListStorage.getListen();
    setState(() {
      _listen = daten;
    });
  }

  void _neueListeErstellen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NameEingebenScreen()),
    );

    if (result == true) {
      _laden(); // reload saved lists
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Einkaufslisten")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _neueListeErstellen,
            child: const Text("Erstellen"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _listen.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_listen[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
