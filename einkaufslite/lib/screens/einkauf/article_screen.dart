import 'package:einkaufslite/models/article.dart';
import 'package:einkaufslite/services/database.dart';
import 'package:einkaufslite/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:einkaufslite/utils/logger.dart';


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
      log.w('Fehler beim Aktualisieren: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Artikel bearbeiten'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Artikelname',
                            prefixIcon: Icon(Icons.edit),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Notiz',
                            prefixIcon: Icon(Icons.notes),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Änderungen speichern'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _saveChanges,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
