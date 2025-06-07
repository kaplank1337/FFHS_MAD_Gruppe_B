import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:einkaufslite/models/article.dart';
import 'package:einkaufslite/models/shoppinglist.dart';
import 'package:einkaufslite/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  Future<void> addUserData(String email) async {
    return await userCollection.doc(uid).set({"email": email});
  }

  Future<void> updateUserData(String email) async {
    return await userCollection.doc(uid).set({"email": email});
  }

  Stream<List<MapEntry<String, Shoppinglist>>> saleStream(String uid) {
    final sharedWithQuery = FirebaseFirestore.instance
        .collection('shoppinglist')
        .where('sharedWith', arrayContains: uid)
        .withConverter<Shoppinglist>(
          fromFirestore: Shoppinglist.fromFirestore,
          toFirestore: (Shoppinglist s, _) => s.toFirestore(),
        )
        .snapshots();

    final ownedQuery = FirebaseFirestore.instance
        .collection('shoppinglist')
        .where('userId', isEqualTo: uid)
        .withConverter<Shoppinglist>(
          fromFirestore: Shoppinglist.fromFirestore,
          toFirestore: (Shoppinglist s, _) => s.toFirestore(),
        )
        .snapshots();

    return Rx.combineLatest2(
      ownedQuery,
      sharedWithQuery,
      (
        QuerySnapshot<Shoppinglist> owned,
        QuerySnapshot<Shoppinglist> shared,
      ) {
        final allDocs = [...owned.docs, ...shared.docs];
        final unique = {
          for (var doc in allDocs) doc.id: doc.data(),
        };
        return unique.entries.toList();
      },
    );
  }

  Stream<QuerySnapshot<Article>> articleStream(String uid) {
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

  Future<void> createShoppingList(String listName) async {
  try {
    final listRef = await FirebaseFirestore.instance.collection('shoppinglist').add({
      'name': listName,
      'userId': uid,
      'sharedWith': [uid],
    });

    await FirebaseAnalytics.instance.logEvent(
      name: 'shopping_list_created',
      parameters: {
        'list_name': listName,
        'user_id': uid ?? 'unknown_user',
        'list_id': listRef.id,
      },
    );
  } catch (e) {
    log.w('Fehler beim Erstellen der Einkaufsliste: $e');
  }
}


  Future<void> createArticle(String listId, String name, String note) async {
    final docRef = FirebaseFirestore.instance
        .collection('shoppinglist')
        .doc(listId)
        .collection('article');

    await docRef.add({'name': name, 'note': note});

    await FirebaseAnalytics.instance.logEvent(
      name: 'article_created',
      parameters: {
        'list_id': listId,
        'name': name,
        'user_id': uid ?? 'unknown_user',
      },
    );
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

    await FirebaseAnalytics.instance.logEvent(
    name: 'shopping_list_deleted',
    parameters: {
      'list_id': listId,
      'user_id': uid ?? 'unknown_user',
    },
    );
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

  Future<void> shareShoppingList(String listId, String emailOrUid) async {
    final docRef =
        FirebaseFirestore.instance.collection('shoppinglist').doc(listId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() as Map<String, dynamic>;

      List<dynamic> sharedWith = data['sharedWith'] ?? [];

      if (!sharedWith.contains(emailOrUid)) {
        sharedWith.add(emailOrUid);
        transaction.update(docRef, {'sharedWith': sharedWith});
      }
    });

  await FirebaseAnalytics.instance.logEvent(
  name: 'shopping_list_shared',
  parameters: {
    'list_id': listId,
    'shared_with': emailOrUid,
    'user_id': uid ?? 'unknown_user',
  },
  );
  }
}
