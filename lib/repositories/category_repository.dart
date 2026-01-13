import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_tag.dart';

class CategoryRepository {
  static const String _key = 'user_categories';

  // 全カテゴリ取得 (保存がない場合はデフォルトを返す)
  Future<List<CategoryTag>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return List.from(defaultCategories);
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => CategoryTag.fromJson(e)).toList();
  }

  // カテゴリ保存
  Future<void> _saveCategories(List<CategoryTag> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  // 追加
  Future<void> addCategory(CategoryTag tag) async {
    final list = await getCategories();
    // 同名チェック（上書きしない）
    if (list.any((e) => e.label == tag.label)) return;

    list.add(tag);
    await _saveCategories(list);
  }

  // 削除
  Future<void> deleteCategory(String label) async {
    final list = await getCategories();
    list.removeWhere((e) => e.label == label);
    await _saveCategories(list);
  }

  // 初期化（リセット）
  Future<void> resetToDefault() async {
    await _saveCategories(defaultCategories);
  }
}
