import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:einkaufslite/models/article.dart';
import 'package:einkaufslite/models/shoppinglist.dart';

class DatabaseService {
  // user uid von authentication
  final String? uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection("users");

  Future addUserData(String email) async {
    return await userCollection.doc(uid).set({"email": email});
  }

  Future updateUserData(String email) async {
    return await userCollection.doc(uid).set({"email": email});
  }

  /*
  // userData from snapshot
  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return UserData(
      uid: uid,
      name: data["name"],
    );
  }
  */

  /*
  // get user doc stream
  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
  */

  Stream<QuerySnapshot<Shoppinglist>> saleStream() {
    return FirebaseFirestore.instance
        .collection('shoppinglist')
        .where('sharedwith', arrayContains: uid)
        .withConverter<Shoppinglist>(
          fromFirestore: Shoppinglist.fromFirestore,
          toFirestore: (Shoppinglist s, _) => s.toFirestore(),
        )
        .snapshots();
  }

  Stream<QuerySnapshot<Article>> articleStream(String uid) {
    print("uid");
    print(uid);
    return FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(uid)
        .collection("article")
        .withConverter<Article>(
          fromFirestore: Article.fromFirestore,
          toFirestore: (Article s, _) => s.toFirestore(),
        )
        .snapshots();
  }

  // Einkaufsliste erstellen
  Future<void> createShoppingList(String listName) async {
    try {
      await FirebaseFirestore.instance.collection('shoppinglist').add({
        'name': listName,
        'userId': uid,
        'sharedWith': [uid],
      });
    } catch (e) {
      print('Fehler beim Erstellen der Einkaufsliste: $e');
    }
  }

  // Artikel erstellen
  Future<void> createArticle(String listId, String name, String note) async {
    final docRef = FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(listId)
        .collection('article');

    await docRef.add({'name': name, 'note': note});
  }

  Future<void> updateArticle(
    String listId,
    String articleId,
    String name,
    String note,
  ) async {
    final docRef = FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(listId)
        .collection('article')
        .doc(articleId);

    await docRef.update({'name': name, 'note': note});
  }

  Future<void> deleteArticle(String listId, String articleId) async {
    final docRef = FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(listId)
        .collection('article')
        .doc(articleId);

    await docRef.delete();
  }

  Future<void> updateShoppingListName(String listId, String newName) async {
    await FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(listId)
        .update({'name': newName});
  }

  Future<void> deleteShoppingList(String listId) async {
    await FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(listId)
        .delete();
  }

  Future<void> updateArticleStatus(
    String listId,
    String articleId,
    bool salestatus,
  ) async {
    await FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(listId)
        .collection('article')
        .doc(articleId)
        .update({'salestatus': salestatus});
  }

  Future<void> shareShoppingList(String listId, String email) async {
    final docRef = FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(listId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() as Map<String, dynamic>;

      List<dynamic> sharedWith = data['sharedwith'] ?? [];

      if (!sharedWith.contains(email)) {
        sharedWith.add(email);
        transaction.update(docRef, {'sharedwith': sharedWith});
      }
    });
  }
}
