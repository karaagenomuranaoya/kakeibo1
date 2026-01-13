import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_tag.dart';

// ショートカット用のデータモデル
class ShortcutItem {
  final String label;
  final String key; // 'expense' or 'payment'
  final Color color;
  final IconData icon;
  final String id; // 保存用の識別子

  ShortcutItem({
    required this.label,
    required this.key,
    required this.color,
    required this.icon,
    required this.id,
  });
}

class SettingsRepository {
  static const String _key = 'shortcut_settings';
  static const String _defaultPaymentKey = 'default_payment_label'; // 追加

  // 全ての選択可能なショートカット候補
  List<ShortcutItem> getAllCandidates() {
    List<ShortcutItem> items = [];

    // 1. デフォルト（費目）
    items.add(
      ShortcutItem(
        label: 'デフォルト',
        key: 'expense',
        color: Colors.blueGrey,
        icon: Icons.bookmarks,
        id: 'def_expense',
      ),
    );

    // 2. 費目リスト
    for (var tag in expenseTags) {
      items.add(
        ShortcutItem(
          label: tag.label,
          key: 'expense',
          color: tag.color,
          icon: _getIconForLabel(tag.label),
          id: 'exp_${tag.label}',
        ),
      );
    }

    // 3. デフォルト（支払い・現金含む）
    items.add(
      ShortcutItem(
        label: 'デフォルト',
        key: 'payment',
        color: Colors.grey,
        icon: Icons.wallet, // お財布アイコン
        id: 'def_payment',
      ),
    );

    // 4. 支払い方法リスト
    for (var tag in paymentTags) {
      items.add(
        ShortcutItem(
          label: tag.label,
          key: 'payment',
          color: tag.color,
          icon: tag.label == 'クレジットカード' ? Icons.credit_card : Icons.payment,
          id: 'pay_${tag.label}',
        ),
      );
    }

    return items;
  }

  // 初期設定（保存データがない場合）
  List<String> get _defaultShortcutIds => [
    'def_expense', // デフォルト
    'exp_食費', // 食費
    'pay_クレジットカード', // クレカ
  ];

  // 保存されたショートカットIDリストを取得
  Future<List<String>> loadShortcutIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? _defaultShortcutIds;
  }

  // ショートカットIDリストを保存
  Future<void> saveShortcutIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }

  // IDリストから実際のオブジェクトリストへ変換して取得
  Future<List<ShortcutItem>> getActiveShortcuts() async {
    final savedIds = await loadShortcutIds();
    final all = getAllCandidates();

    // 保存された順序を維持してリストを作成
    List<ShortcutItem> active = [];
    for (var id in savedIds) {
      try {
        final item = all.firstWhere((e) => e.id == id);
        active.add(item);
      } catch (e) {
        // 定義が変わってIDが見つからない場合はスキップ
      }
    }
    return active;
  }

  // アイコンの自動判定（簡易実装）
  IconData _getIconForLabel(String label) {
    if (label.contains('食')) return Icons.restaurant;
    if (label.contains('日用')) return Icons.shopping_bag;
    if (label.contains('交際')) return Icons.people;
    if (label.contains('趣味')) return Icons.sports_esports;
    if (label.contains('雑')) return Icons.auto_awesome;
    return Icons.label;
  }

  // ▼▼▼ 以下、追加機能 ▼▼▼

  // デフォルトの支払い方法を取得
  Future<String?> loadDefaultPaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultPaymentKey);
  }

  // デフォルトの支払い方法を保存
  Future<void> saveDefaultPaymentMethod(String label) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultPaymentKey, label);
  }

  // 設定を削除（「設定なし」に戻す場合など）
  Future<void> clearDefaultPaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_defaultPaymentKey);
  }
}
