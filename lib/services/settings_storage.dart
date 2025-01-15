import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static Future<void> saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? 'default_value';
  }
}