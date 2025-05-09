import 'package:cloud_firestore/cloud_firestore.dart';

class Shoppinglist {
  final String? name;
  final String? userId;
  final List<String>? sharedWith;

  Shoppinglist({this.name, this.userId, this.sharedWith});

  factory Shoppinglist.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Shoppinglist(
      name: data?['name'],
      userId: data?['userid'],
      sharedWith:
          data?['sharedwith'] != null
              ? List<String>.from(data!['sharedwith'])
              : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (userId != null) 'userid': userId,
      if (sharedWith != null) 'sharedwith': sharedWith,
    };
  }
}
