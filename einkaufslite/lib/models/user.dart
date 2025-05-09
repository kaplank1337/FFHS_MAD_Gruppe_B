class UserModel {
  final String? uid;
  UserModel({this.uid});
}

class UserData {
  final String? uid;
  final String? name;
  final String? sugars;
  final int? strength;

  UserData({this.uid, this.sugars, this.strength, this.name});
}
