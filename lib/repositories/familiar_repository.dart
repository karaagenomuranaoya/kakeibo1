import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/familiar.dart';

class FamiliarRepository {
  static const String _keyEggClicks = 'egg_current_clicks';
  static const String _keyHatchedCount = 'egg_hatched_count';
  static const String _keyCollection = 'familiar_collection_ids';
  // ★追加
  static const String _keyBuddyId = 'familiar_buddy_id';

  // ... (既存のメソッド: getEggStatus, addEggClick, hatchEgg はそのまま) ...

  // 現在の卵の状態を取得
  Future<Map<String, int>> getEggStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final clicks = prefs.getInt(_keyEggClicks) ?? 0;
    final hatchedCount = prefs.getInt(_keyHatchedCount) ?? 0;
    final requiredClicks = 5 + (hatchedCount * 5);
    return {
      'current': clicks,
      'required': requiredClicks,
      'hatchedCount': hatchedCount,
    };
  }

  Future<void> addEggClick() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyEggClicks) ?? 0;
    await prefs.setInt(_keyEggClicks, current + 1);
  }

  Future<Familiar?> hatchEgg() async {
    final status = await getEggStatus();
    if (status['current']! < status['required']!) return null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyEggClicks, 0);
    await prefs.setInt(_keyHatchedCount, status['hatchedCount']! + 1);

    final rnd = Random();
    final roll = rnd.nextInt(100);
    int targetRarity;
    if (roll < 50)
      targetRarity = 1;
    else if (roll < 80)
      targetRarity = 2;
    else if (roll < 95)
      targetRarity = 3;
    else if (roll < 99)
      targetRarity = 4;
    else
      targetRarity = 5;

    final candidates = familiarMasterList
        .where((f) => f.rarity == targetRarity)
        .toList();
    final hit = candidates.isNotEmpty
        ? candidates[rnd.nextInt(candidates.length)]
        : familiarMasterList[0];

    final collection = prefs.getStringList(_keyCollection) ?? [];
    if (!collection.contains(hit.id)) {
      collection.add(hit.id);
      await prefs.setStringList(_keyCollection, collection);
    }
    return hit;
  }

  // 持っている使い魔リストを取得
  Future<List<Familiar>> getMyCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_keyCollection) ?? [];
    return familiarMasterList.where((f) => ids.contains(f.id)).toList();
  }

  // ★★★ 追加: バディ機能 ★★★

  // バディを設定
  Future<void> setBuddy(String familiarId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBuddyId, familiarId);
  }

  // 現在のバディを取得
  Future<Familiar?> getBuddy() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyBuddyId);
    if (id == null) return null;

    try {
      return familiarMasterList.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }
}
