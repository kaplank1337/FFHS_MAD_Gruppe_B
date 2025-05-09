import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String? name;
  final String? note;
  final bool? salestatus;

  Article({this.name, this.note, this.salestatus});

  factory Article.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return Article(
      name: data['name'],
      note: data['note'],
      salestatus: data['salestatus'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'note': note, 'salestatus': salestatus ?? false};
  }
}
