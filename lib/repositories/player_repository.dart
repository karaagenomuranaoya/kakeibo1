import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/shop_item.dart'; // 追加

class PlayerRepository {
  static const String _keyScore = 'player_total_score'; // CP
  static const String _keyRealSpending = 'player_real_spending'; // リアル支出
  static const String _keyXp = 'player_xp';
  static const String _keyInputCount = 'player_input_count';
  static const String _keyUnlockedAchievements = 'player_unlocked_ids';

  // ★追加キー
  static const String _keyPurchasedItems =
      'player_purchased_items'; // 購入済みアイテムIDリスト
  static const String _keyEquippedSkin = 'player_equipped_skin'; // 装備中のスキンID

  Future<Map<String, dynamic>> getPlayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_keyXp) ?? 0;
    final cp = prefs.getInt(_keyScore) ?? 0;
    final inputCount = prefs.getInt(_keyInputCount) ?? 0;
    final realSpending = prefs.getInt(_keyRealSpending) ?? cp;

    int level = 1 + (xp / 5000).floor();
    int currentLevelBaseXp = (level - 1) * 5000;
    int nextLevelBaseXp = level * 5000;
    double progress =
        (xp - currentLevelBaseXp) / (nextLevelBaseXp - currentLevelBaseXp);

    return {
      'level': level,
      'xp': xp,
      'progress': progress,
      'cp': cp,
      'realSpending': realSpending,
      'inputCount': inputCount,
    };
  }

  // 現在の倍率（Multiplier）を計算して返す
  Future<double> getCurrentMultiplier() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasedIds = prefs.getStringList(_keyPurchasedItems) ?? [];

    double multiplier = 1.0; // 基本倍率

    for (var item in darkWebItems) {
      if (item.type == ShopItemType.multiplier &&
          purchasedIds.contains(item.id)) {
        multiplier += (item.effectValue ?? 0.0);
      }
    }
    return multiplier;
  }

  // 現在装備中のスキンIDを取得
  Future<String?> getEquippedSkin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEquippedSkin);
  }

  // スキンを変更
  Future<void> equipSkin(String? skinId) async {
    final prefs = await SharedPreferences.getInstance();
    if (skinId == null) {
      await prefs.remove(_keyEquippedSkin);
    } else {
      await prefs.setString(_keyEquippedSkin, skinId);
    }
  }

  // アイテム購入処理
  Future<bool> purchaseItem(ShopItem item) async {
    final prefs = await SharedPreferences.getInstance();
    int currentCp = prefs.getInt(_keyScore) ?? 0;

    // お金が足りない
    if (currentCp < item.price) return false;

    // 支払い
    await prefs.setInt(_keyScore, currentCp - item.price);

    // アイテム付与
    List<String> purchased = prefs.getStringList(_keyPurchasedItems) ?? [];
    if (!purchased.contains(item.id)) {
      purchased.add(item.id);
      await prefs.setStringList(_keyPurchasedItems, purchased);
    }

    return true;
  }

  // 購入済みリスト取得
  Future<List<String>> getPurchasedItemIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPurchasedItems) ?? [];
  }

  Future<List<String>> getUnlockedAchievementIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyUnlockedAchievements) ?? [];
  }

  // スコア加算（InputScreenで計算した最終CPを受け取る形に変更してもいいが、ここでは既存ロジックを維持）
  // ★修正: InputScreen側で倍率計算済みのCPを受け取るように引数を変更するのが筋だが、
  // 既存メソッド `addScoreAndCheckAchievements` は amount(元の金額) を受け取って内部でCP計算させたい。
  // しかし、倍率計算は非同期なので、InputScreen側で「金額 × 倍率」を計算して渡す形に変更する。

  // 新しい加算メソッド: amount(リアル) と gainedCp(ゲーム内) を分けて受け取る
  Future<List<Achievement>> addTransactionData({
    required int realAmount,
    required int gainedCp,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. CP加算
    int currentCp = prefs.getInt(_keyScore) ?? 0;
    await prefs.setInt(_keyScore, currentCp + gainedCp);

    // 2. リアル支出加算
    int currentReal = prefs.getInt(_keyRealSpending) ?? currentCp; // 初期化対応
    await prefs.setInt(_keyRealSpending, currentReal + realAmount);

    // 3. XPと回数
    int currentXp = prefs.getInt(_keyXp) ?? 0;
    await prefs.setInt(_keyXp, currentXp + realAmount); // XPはリアル金額ベースが健全

    int currentCount = prefs.getInt(_keyInputCount) ?? 0;
    int newCount = currentCount + 1;
    await prefs.setInt(_keyInputCount, newCount);

    // 4. 実績解除チェック
    List<String> unlockedIds =
        prefs.getStringList(_keyUnlockedAchievements) ?? [];
    List<Achievement> newUnlocked = [];

    for (var achievement in allAchievements) {
      if (unlockedIds.contains(achievement.id)) continue;

      bool isUnlocked = false;
      if (achievement.type == AchievementType.totalAmount) {
        // 金額実績はインフレ後のCPで判定（気持ちよさ優先）
        if ((currentCp + gainedCp) >= achievement.threshold) isUnlocked = true;
      } else if (achievement.type == AchievementType.inputCount) {
        if (newCount >= achievement.threshold) isUnlocked = true;
      }

      if (isUnlocked) {
        unlockedIds.add(achievement.id);
        newUnlocked.add(achievement);
      }
    }

    if (newUnlocked.isNotEmpty) {
      await prefs.setStringList(_keyUnlockedAchievements, unlockedIds);
    }

    return newUnlocked;
  }

  // 旧メソッドは非推奨にするが、エラー回避のため残すか、InputScreenを修正する。
  // 今回はInputScreenを修正するので、この新しい `addTransactionData` を使う。
  Future<List<Achievement>> addScoreAndCheckAchievements(int amount) async {
    // 互換性維持のため、倍率1.0として処理
    return addTransactionData(realAmount: amount, gainedCp: amount);
  }
}
