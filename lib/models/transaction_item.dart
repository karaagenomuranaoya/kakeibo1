class TransactionItem {
  final int amount;
  final String expense;
  final String payment;
  final DateTime date;
  final String? memo; // 追加: 任意のメモ

  TransactionItem({
    required this.amount,
    required this.expense,
    required this.payment,
    required this.date,
    this.memo,
  });

  // 表示用日付フォーマット
  String get displayDate {
    return "${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  // JSON保存用: Mapに変換
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'expense': expense,
      'payment': payment,
      'date_iso': date.toIso8601String(),
      'memo': memo, // 追加
    };
  }

  // 読み込み用: Mapから生成
  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      amount: json['amount'] as int,
      expense: json['expense'] as String,
      payment: json['payment'] as String,
      date: DateTime.parse(json['date_iso'] as String),
      memo: json['memo'] as String?, // 追加
    );
  }
}
