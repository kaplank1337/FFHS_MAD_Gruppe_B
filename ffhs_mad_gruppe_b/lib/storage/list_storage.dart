import 'package:shared_preferences/shared_preferences.dart';

class ListStorage {
  static const _key = 'einkaufslisten';

  static Future<List<String>> getListen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> speichern(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final listen = prefs.getStringList(_key) ?? [];
    if (!listen.contains(name)) {
      listen.add(name);
      await prefs.setStringList(_key, listen);
    }
  }
}
