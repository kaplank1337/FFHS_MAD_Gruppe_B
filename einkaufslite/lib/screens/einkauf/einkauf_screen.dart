import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:einkaufslite/models/article.dart';
import 'package:einkaufslite/services/database.dart';
import 'package:einkaufslite/widgets/app_background.dart';
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
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Tippe auf einen Artikel zum Bearbeiten.\nLange drücken zum Löschen.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: _buildArticleList()),
        ],
      ),
    );
  }

  Widget _buildArticleList() {
    return StreamBuilder<QuerySnapshot<Article>>(
      stream: _databaseServices.articleStream(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Fehler beim Laden der Artikel');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final article = doc.data();
            final isChecked = article.salestatus ?? false;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isChecked
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.white.withOpacity(0.95),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Checkbox(
                    value: isChecked,
                    activeColor: Colors.teal,
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
                      fontWeight: FontWeight.w600,
                      decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked ? Colors.black45 : Colors.black87,
                    ),
                  ),
                  subtitle: article.note?.isNotEmpty ?? false
                      ? Text(
                          article.note!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isChecked
                                ? Colors.black38
                                : Colors.black54,
                          ),
                        )
                      : null,
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
                ),
              ),
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
      builder: (context) => AlertDialog(
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
                await _databaseServices.deleteArticle(widget.uid, articleId);
                Navigator.of(context).pop();
              } catch (e) {
                print('Fehler beim Löschen: $e');
              }
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    final TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  final querySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('shoppinglist')
                        .doc(widget.uid)
                        .update({
                      'sharedwith': FieldValue.arrayUnion([email]),
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Einkaufsliste erfolgreich geteilt!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('E-Mail-Adresse nicht gefunden!'),
                      ),
                    );
                  }
                } catch (e) {
                  print('Fehler beim Teilen: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Fehler beim Teilen der Einkaufsliste.'),
                    ),
                  );
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
