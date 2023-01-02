// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

/// flutter_session
/// A package that adds session functionality to Flutter
class FlutterSession {
  /// Initialize session container
  final Map _session = {};

  // Yes, it uses SharedPreferences
   SharedPreferences prefs;

  // Initialize the SharedPreferences instance
  Future _initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Item setter
  ///
  /// @param key String
  /// @returns Future
  Future get(key) async {
    await _initSharedPrefs();
    try {
      if (prefs.get(key) != null) {
        return json.decode(prefs.get(key) as String);
      }
      return prefs.get(key);
    } catch (e) {
      return prefs.get(key);
    }
  }

  /// Item setter
  ///
  /// @param key String
  /// @param value any
  /// @returns Future
  Future set(key, value) async {
    await _initSharedPrefs();

    // Detect item type
    switch (value.runtimeType) {
    // String
      case String:
        {
          await prefs.setString(key, value);
        }
        break;

    // Integer
      case int:
        {
          await prefs.setInt(key, value);
        }
        break;

    // Boolean
      case bool:
        {
          await prefs.setBool(key, value);
        }
        break;

    // Double
      case double:
        {
          await prefs.setDouble(key, value);
        }
        break;

    // List<String>
      case List:
        {
          await prefs.setStringList(key, value);
        }
        break;

    // Object
      default:
        {
          await prefs.setString(key, jsonEncode(value.toJson()));
        }
    }

    // Add item to session container
    _session.putIfAbsent(key, () => value);
  }
}