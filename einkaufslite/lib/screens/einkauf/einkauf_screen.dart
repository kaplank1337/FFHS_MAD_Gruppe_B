import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:einkaufslite/models/article.dart';
import 'package:einkaufslite/services/database.dart';
import 'package:flutter/material.dart';

class EinkaufScreen extends StatefulWidget {
  final String uid;

  const EinkaufScreen({super.key, required this.uid});

  @override
  State<EinkaufScreen> createState() => _EinkaufScreenState();
}

class _EinkaufScreenState extends State<EinkaufScreen> {
  final DatabaseService _databaseServices = DatabaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einkauf"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareDialog,
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddArticleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(children: [Expanded(child: _buildArticleList())]),
    );
  }

  Widget _buildArticleList() {
    return StreamBuilder<QuerySnapshot<Article>>(
      stream: _databaseServices.articleStream(widget.uid),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Article>> snapshot,
      ) {
        if (snapshot.hasError) {
          return const Text('Fehler beim Laden der Artikel');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children:
              snapshot.data!.docs.map((doc) {
                final article = doc.data();
                return ListTile(
                  leading: Checkbox(
                    value: article.salestatus ?? false,
                    onChanged: (bool? newValue) async {
                      try {
                        await _databaseServices.updateArticleStatus(
                          widget.uid,
                          doc.id,
                          newValue ?? false,
                        );
                      } catch (e) {
                        print('Fehler beim Aktualisieren des Status: $e');
                      }
                    },
                  ),
                  title: Text(
                    article.name ?? 'Kein Name',
                    style: TextStyle(
                      decoration:
                          (article.salestatus ?? false)
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(article.note ?? ''),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/article',
                      arguments: {
                        'listId': widget.uid,
                        'articleId': doc.id,
                        'article': article,
                      },
                    );
                  },
                  onLongPress: () {
                    _showDeleteConfirmation(doc.id);
                  },
                );
              }).toList(),
        );
      },
    );
  }

  void _showAddArticleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neuen Artikel hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Artikelname'),
              ),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Notiz'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final note = _noteController.text.trim();

                if (name.isNotEmpty) {
                  try {
                    await _databaseServices.createArticle(
                      widget.uid,
                      name,
                      note,
                    );
                    Navigator.of(context).pop();
                    _nameController.clear();
                    _noteController.clear();
                  } catch (e) {
                    print('Fehler beim Speichern des Artikels: $e');
                  }
                } else {
                  print('Name darf nicht leer sein');
                }
              },
              child: const Text('Speichern'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(String articleId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Artikel löschen'),
            content: const Text('Möchtest du diesen Artikel wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _databaseServices.deleteArticle(
                      widget.uid,
                      articleId,
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Fehler beim Löschen: $e');
                  }
                },
                child: const Text(
                  'Löschen',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showShareDialog() {
    final TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Einkaufsliste teilen'),
            content: TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-Mail-Adresse des Empfängers',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('shoppinglist')
                          .doc(widget.uid)
                          .update({
                            'sharedwith': FieldValue.arrayUnion([email]),
                          });
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Fehler beim Teilen: $e');
                    }
                  }
                },
                child: const Text('Teilen'),
              ),
            ],
          ),
    );
  }
}
