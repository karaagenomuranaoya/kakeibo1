import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _keyAllowEmpty = 'setting_allow_empty_category';
  static const String _keyDefaultName = 'setting_default_category_name';

  // カテゴリなしでの入力を許可するか (初期値: true)
  Future<bool> getAllowEmptyCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAllowEmpty) ?? true;
  }

  Future<void> setAllowEmptyCategory(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAllowEmpty, value);
  }

  // デフォルトカテゴリの名前 (初期値: "Daily Damage")
  Future<String> getDefaultCategoryName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultName) ?? 'Daily Damage';
  }

  Future<void> setDefaultCategoryName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultName, name);
  }
}
