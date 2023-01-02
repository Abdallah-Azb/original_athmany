import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  Preference._();

  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<String> getItem(String name) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getString(name) ?? '';
  }

  static Future<bool> setItem(String name, String value) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.setString(name, value);
  }

  static Future<Set<String>> getAll() async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getKeys();
  }
}
