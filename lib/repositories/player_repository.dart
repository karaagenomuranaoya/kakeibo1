import 'package:shared_preferences/shared_preferences.dart';

class PlayerRepository {
  static const String _keyScore = 'player_total_score'; // 累計金額（CP）
  static const String _keyXp = 'player_xp'; // 経験値
  // static const String _keyLevel = 'player_level'; // レベルはXPから計算するので保存不要

  // 累計CP取得
  Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScore) ?? 0;
  }

  // 現在のレベルと次のレベルまでのXP割合を取得
  Future<Map<String, dynamic>> getLevelStats() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_keyXp) ?? 0;

    // レベル計算式: 経験値の平方根 * 係数 (簡易的なRPG曲線)
    // 例: 10,000円使う -> √10000 = 100 -> Lv.10 (係数0.1の場合)
    // ここではシンプルに: Lv = 1 + (xp / 5000) の整数部 とする
    int level = 1 + (xp / 5000).floor();

    // 次のレベルまでの進捗 (0.0 ~ 1.0)
    int currentLevelBaseXp = (level - 1) * 5000;
    int nextLevelBaseXp = level * 5000;
    double progress =
        (xp - currentLevelBaseXp) / (nextLevelBaseXp - currentLevelBaseXp);

    return {'level': level, 'xp': xp, 'progress': progress};
  }

  // スコアと経験値を加算
  Future<void> addScore(int amount) async {
    final prefs = await SharedPreferences.getInstance();

    // CP加算
    int currentScore = prefs.getInt(_keyScore) ?? 0;
    await prefs.setInt(_keyScore, currentScore + amount);

    // XP加算（浪費ボーナス：高額なほど経験値倍率が上がる演出を入れてもいいが、まずは等倍）
    int currentXp = prefs.getInt(_keyXp) ?? 0;
    await prefs.setInt(_keyXp, currentXp + amount);
  }
}
