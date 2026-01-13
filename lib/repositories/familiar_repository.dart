import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/familiar.dart';

class FamiliarRepository {
  static const String _keyEggClicks = 'egg_current_clicks';
  static const String _keyHatchedCount = 'egg_hatched_count';
  static const String _keyCollection = 'familiar_collection_ids';

  // 現在の卵の状態を取得
  Future<Map<String, int>> getEggStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final clicks = prefs.getInt(_keyEggClicks) ?? 0;
    final hatchedCount = prefs.getInt(_keyHatchedCount) ?? 0;

    // 必要クリック数計算: 最初は5回、以降 5 + (孵化数 * 5) ずつ増える
    // 例: 5, 10, 15, 20...
    final requiredClicks = 5 + (hatchedCount * 5);

    return {
      'current': clicks,
      'required': requiredClicks,
      'hatchedCount': hatchedCount,
    };
  }

  // 入力時に呼ぶ：クリック数を加算
  Future<void> addEggClick() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyEggClicks) ?? 0;
    await prefs.setInt(_keyEggClicks, current + 1);
  }

  // 卵を割る処理
  Future<Familiar?> hatchEgg() async {
    final status = await getEggStatus();
    if (status['current']! < status['required']!) {
      return null; // まだ割れない
    }

    final prefs = await SharedPreferences.getInstance();

    // 1. カウントリセット & 孵化回数インクリメント
    await prefs.setInt(_keyEggClicks, 0);
    await prefs.setInt(_keyHatchedCount, status['hatchedCount']! + 1);

    // 2. 抽選ロジック
    final rnd = Random();
    final roll = rnd.nextInt(100); // 0-99

    // 確率設定
    int targetRarity;
    if (roll < 50)
      targetRarity = 1; // 50% Common
    else if (roll < 80)
      targetRarity = 2; // 30% Rare
    else if (roll < 95)
      targetRarity = 3; // 15% Epic
    else if (roll < 99)
      targetRarity = 4; // 4% Legendary
    else
      targetRarity = 5; // 1% God

    // 該当レアリティの中からランダムに1体選出
    final candidates = familiarMasterList
        .where((f) => f.rarity == targetRarity)
        .toList();
    // もし候補がいなければ(Godなど)、レアリティを下げて再検索（安全策）
    final hit = candidates.isNotEmpty
        ? candidates[rnd.nextInt(candidates.length)]
        : familiarMasterList[0];

    // 3. コレクションに追加
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
}
