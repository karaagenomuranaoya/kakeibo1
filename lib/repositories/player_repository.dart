import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/shop_item.dart';

class PlayerRepository {
  // ★修正: _keyScore -> _keyBudgetDamage
  static const String _keyBudgetDamage = 'player_total_score'; // 実体は互換性維持
  static const String _keyRealSpending = 'player_real_spending';
  static const String _keyXp = 'player_xp';
  static const String _keyInputCount = 'player_input_count';
  static const String _keyUnlockedAchievements = 'player_unlocked_ids';
  static const String _keyPurchasedItems = 'player_purchased_items';
  static const String _keyEquippedSkin = 'player_equipped_skin';

  Future<Map<String, dynamic>> getPlayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_keyXp) ?? 0;
    // ★修正: cp -> bd
    final bd = prefs.getInt(_keyBudgetDamage) ?? 0;
    final inputCount = prefs.getInt(_keyInputCount) ?? 0;
    final realSpending = prefs.getInt(_keyRealSpending) ?? bd;

    int level = 1 + (xp / 5000).floor();
    int currentLevelBaseXp = (level - 1) * 5000;
    int nextLevelBaseXp = level * 5000;
    double progress =
        (xp - currentLevelBaseXp) / (nextLevelBaseXp - currentLevelBaseXp);

    return {
      'level': level,
      'xp': xp,
      'progress': progress,
      'bd': bd, // ★修正
      'realSpending': realSpending,
      'inputCount': inputCount,
    };
  }

  Future<double> getCurrentMultiplier() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasedIds = prefs.getStringList(_keyPurchasedItems) ?? [];

    double multiplier = 1.0;

    for (var item in darkWebItems) {
      if (item.type == ShopItemType.multiplier &&
          purchasedIds.contains(item.id)) {
        multiplier += (item.effectValue ?? 0.0);
      }
    }
    return multiplier;
  }

  Future<String?> getEquippedSkin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEquippedSkin);
  }

  Future<void> equipSkin(String? skinId) async {
    final prefs = await SharedPreferences.getInstance();
    if (skinId == null) {
      await prefs.remove(_keyEquippedSkin);
    } else {
      await prefs.setString(_keyEquippedSkin, skinId);
    }
  }

  Future<bool> purchaseItem(ShopItem item) async {
    final prefs = await SharedPreferences.getInstance();
    int currentBd = prefs.getInt(_keyBudgetDamage) ?? 0;

    if (currentBd < item.price) return false;

    await prefs.setInt(_keyBudgetDamage, currentBd - item.price);

    List<String> purchased = prefs.getStringList(_keyPurchasedItems) ?? [];
    if (!purchased.contains(item.id)) {
      purchased.add(item.id);
      await prefs.setStringList(_keyPurchasedItems, purchased);
    }

    return true;
  }

  Future<List<String>> getPurchasedItemIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPurchasedItems) ?? [];
  }

  Future<List<String>> getUnlockedAchievementIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyUnlockedAchievements) ?? [];
  }

  Future<List<Achievement>> addTransactionData({
    required int realAmount,
    required int gainedBd, // ★修正
  }) async {
    final prefs = await SharedPreferences.getInstance();

    int currentBd = prefs.getInt(_keyBudgetDamage) ?? 0;
    await prefs.setInt(_keyBudgetDamage, currentBd + gainedBd);

    int currentReal = prefs.getInt(_keyRealSpending) ?? currentBd;
    await prefs.setInt(_keyRealSpending, currentReal + realAmount);

    int currentXp = prefs.getInt(_keyXp) ?? 0;
    await prefs.setInt(_keyXp, currentXp + realAmount);

    int currentCount = prefs.getInt(_keyInputCount) ?? 0;
    int newCount = currentCount + 1;
    await prefs.setInt(_keyInputCount, newCount);

    List<String> unlockedIds =
        prefs.getStringList(_keyUnlockedAchievements) ?? [];
    List<Achievement> newUnlocked = [];

    for (var achievement in allAchievements) {
      if (unlockedIds.contains(achievement.id)) continue;

      bool isUnlocked = false;
      if (achievement.type == AchievementType.totalAmount) {
        // ★修正
        if ((currentBd + gainedBd) >= achievement.threshold) isUnlocked = true;
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

  Future<void> refundRealSpending(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentReal = prefs.getInt(_keyRealSpending) ?? 0;
    int newReal = currentReal - amount;
    if (newReal < 0) newReal = 0;
    await prefs.setInt(_keyRealSpending, newReal);
  }
}
