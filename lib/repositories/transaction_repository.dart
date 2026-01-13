import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';

class TransactionRepository {
  static const String _key = 'history';

  // 保存処理
  Future<void> addTransaction(TransactionItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<TransactionItem> currentList = await getAllTransactions();

    currentList.insert(0, item);

    final String jsonString = json.encode(
      currentList.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }

  // 全件取得処理
  Future<List<TransactionItem>> getAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => TransactionItem.fromJson(e)).toList();
  }

  // ★追加: 削除処理
  Future<void> deleteTransaction(TransactionItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<TransactionItem> currentList = await getAllTransactions();

    // IDを持たないので、日時と金額と費目が一致する最初のデータを削除
    // (厳密にはID導入がベストですが、現状の仕様ならこれで十分動作します)
    currentList.removeWhere(
      (element) =>
          element.date == item.date &&
          element.amount == item.amount &&
          element.expense == item.expense,
    );

    final String jsonString = json.encode(
      currentList.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }
}
