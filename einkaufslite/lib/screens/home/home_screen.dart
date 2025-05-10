import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:einkaufslite/models/shoppinglist.dart';
import 'package:einkaufslite/models/user.dart';
import 'package:einkaufslite/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _databaseServices = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Einkaufsliste"), centerTitle: true),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: _buildTextInputDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(children: [Expanded(child: _buildSaleList())]),
    );
  }

  Widget _buildSaleList() {
    return StreamBuilder<QuerySnapshot<Shoppinglist>>(
      stream: _databaseServices.saleStream(
        FirebaseAuth.instance.currentUser!.uid,
      ),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Shoppinglist>> snapshot,
      ) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final shoppinglist = doc.data();
            final uid = doc.id;

            return ListTile(
              title: Text(shoppinglist.name ?? 'Kein Name'),
              onTap: () {
                Navigator.pushNamed(context, '/sale', arguments: uid);
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
                                await _databaseServices.updateShoppingListName(
                                  uid,
                                  newName,
                                );
                                Navigator.of(context).pop();
                              } catch (e) {
                                print('Fehler beim Umbenennen: $e');
                              }
                            }
                          },
                          child: const Text('Speichern'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await _databaseServices.deleteShoppingList(uid);
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
          title: Text('Einkaufsliste erstellen'),
          content: Consumer<UserModel?>(
            builder: (context, user, child) {
              if (user == null) {
                // Zeige eine Ladeanzeige, wenn der Benutzer nicht geladen wurde
                return const Center(child: CircularProgressIndicator());
              } else {
                // Benutzer wurde erfolgreich geladen, jetzt das Textfeld anzeigen
                print('User UID: ${user.uid}');
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
                // Sicherstellen, dass der Benutzer existiert, bevor wir fortfahren
                final user = Provider.of<UserModel?>(context, listen: false);
                if (user != null && listName.isNotEmpty) {
                  try {
                    // Einkaufsliste in der Datenbank speichern
                    await DatabaseService(
                      uid: user.uid,
                    ).createShoppingList(listName);
                    Navigator.of(context).pop(); // Schließe den Dialog
                    print('Einkaufsliste gespeichert');
                  } catch (e) {
                    print('Fehler beim Speichern der Einkaufsliste: $e');
                  }
                } else {
                  print(
                    'Name der Einkaufsliste darf nicht leer sein oder Benutzer ist nicht angemeldet!',
                  );
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
