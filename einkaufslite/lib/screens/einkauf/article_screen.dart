import 'package:einkaufslite/models/article.dart';
import 'package:einkaufslite/services/database.dart';
import 'package:flutter/material.dart';

class EditArticleScreen extends StatefulWidget {
  final String listId;
  final String articleId;
  final Article article;

  const EditArticleScreen({
    super.key,
    required this.listId,
    required this.articleId,
    required this.article,
  });

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.article.name);
    _noteController = TextEditingController(text: widget.article.note);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final note = _noteController.text.trim();

    if (name.isEmpty) return;

    try {
      await _databaseService.updateArticle(
        widget.listId,
        widget.articleId,
        name,
        note,
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Fehler beim Aktualisieren: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel bearbeiten')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Artikelname'),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Notiz'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Änderungen speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
