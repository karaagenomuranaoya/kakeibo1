class TransactionItem {
  final int amount;
  final String expense;
  // final String payment; // 削除
  final DateTime date;
  final String? memo;

  TransactionItem({
    required this.amount,
    required this.expense,
    // required this.payment, // 削除
    required this.date,
    this.memo,
  });

  String get displayDate {
    return "${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'expense': expense,
      // 'payment': payment, // 削除
      'date_iso': date.toIso8601String(),
      'memo': memo,
    };
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      amount: json['amount'] as int,
      expense: json['expense'] as String,
      // payment: json['payment'] as String, // 削除 (JSONにあっても無視)
      date: DateTime.parse(json['date_iso'] as String),
      memo: json['memo'] as String?,
    );
  }
}
