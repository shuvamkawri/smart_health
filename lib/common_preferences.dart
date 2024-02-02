import 'package:shared_preferences/shared_preferences.dart';

class CommonPreferences {
  static SharedPreferences? _prefs; // Declare _prefs as nullable

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, String value) async {
    if (_prefs != null) {
      await _prefs!.setString(key, value);
    }
  }

  static String getString(String key, [String defaultValue = '']) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  static Future<void> saveBool(String key, bool value) async {
    if (_prefs != null) {
      await _prefs!.setBool(key, value);
    }
  }

  static bool getBool(String key, [bool defaultValue = false]) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static Future<void> saveInt(String key, int value) async {
    if (_prefs != null) {
      await _prefs!.setInt(key, value);
    }
  }

  static int getInt(String key, [int defaultValue = 0]) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  static Future<void> saveDouble(String key, double value) async {
    if (_prefs != null) {
      await _prefs!.setDouble(key, value);
    }
  }

  static double getDouble(String key, [double defaultValue = 0.0]) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  static Future<void> remove(String key) async {
    if (_prefs != null) {
      await _prefs!.remove(key);
    }
  }
}
