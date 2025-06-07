import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:einkaufslite/models/shoppinglist.dart';
import 'package:einkaufslite/models/user.dart';
import 'package:einkaufslite/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:einkaufslite/widgets/app_background.dart';
import 'package:einkaufslite/utils/logger.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _databaseServices = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Einkaufsliste"),
          centerTitle: true,
        ),
        body: SafeArea(child: _buildBody()),
        floatingActionButton: FloatingActionButton(
          onPressed: _buildTextInputDialog,
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
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Tippe auf eine Liste, um sie zu öffnen.\nLange drücken für Bearbeiten oder Löschen.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: _buildSaleList()),
        ],
      ),
    );
  }

  Widget _buildSaleList() {
  return StreamBuilder<List<MapEntry<String, Shoppinglist>>>(
    stream: _databaseServices.saleStream(
      FirebaseAuth.instance.currentUser!.uid,
    ),
    builder: (
      BuildContext context,
      AsyncSnapshot<List<MapEntry<String, Shoppinglist>>> snapshot,
    ) {
      if (snapshot.hasError) {
        return const Text('Etwas ist schiefgelaufen');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final entries = snapshot.data!;

      return ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final docId = entry.key;
          final shoppinglist = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.shopping_cart, color: Colors.teal),
                title: Text(
                  shoppinglist.name ?? 'Kein Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, '/sale', arguments: docId);
                },
                onLongPress: () {
                  final _editController = TextEditingController(
                    text: shoppinglist.name,
                  );

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Einkaufsliste bearbeiten'),
                        content: TextField(
                          controller: _editController,
                          decoration: const InputDecoration(
                            labelText: 'Neuer Name',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              final newName = _editController.text.trim();
                              if (newName.isNotEmpty) {
                                try {
                                  await _databaseServices
                                      .updateShoppingListName(docId, newName);
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  log.w('Fehler beim Umbenennen: $e');
                                }
                              }
                            },
                            child: const Text('Speichern'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await _databaseServices
                                    .deleteShoppingList(docId);
                                Navigator.of(context).pop();
                              } catch (e) {
                                log.w('Fehler beim Löschen: $e');
                              }
                            },
                            child: const Text(
                              'Löschen',
                              style: TextStyle(color: Colors.red),
                            ),
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
                },
              ),
            ),
          );
        },
      );
    },
  );
}

  void _buildTextInputDialog() {
    final _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Einkaufsliste erstellen'),
          content: Consumer<UserModel?>(
            builder: (context, user, child) {
              if (user == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Name der Einkaufsliste',
                  ),
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final listName = _controller.text.trim();
                final user = Provider.of<UserModel?>(context, listen: false);
                if (user != null && listName.isNotEmpty) {
                  try {
                    await DatabaseService(uid: user.uid)
                        .createShoppingList(listName);
                    Navigator.of(context).pop();
                    log.i('Einkaufsliste gespeichert');
                  } catch (e) {
                    log.w('Fehler beim Speichern der Einkaufsliste: $e');
                  }
                } else {
                  log.w(
                      'Name der Einkaufsliste darf nicht leer sein oder Benutzer ist nicht angemeldet!');
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
}
