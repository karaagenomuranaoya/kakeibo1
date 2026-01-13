import 'package:flutter/material.dart';
import '../models/category_tag.dart';
import '../models/transaction_item.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/category_repository.dart';

class MonthlyHistoryScreen extends StatefulWidget {
  const MonthlyHistoryScreen({super.key});
  @override
  State<MonthlyHistoryScreen> createState() => _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends State<MonthlyHistoryScreen> {
  final PageController _pageController = PageController(initialPage: 1000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('月別レポート')),
      body: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final d = DateTime(
            DateTime.now().year,
            DateTime.now().month + (index - 1000),
          );
          return MonthPage(year: d.year, month: d.month);
        },
      ),
    );
  }
}

class MonthPage extends StatefulWidget {
  final int year;
  final int month;
  const MonthPage({super.key, required this.year, required this.month});
  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  List<TransactionItem> _history = [];
  List<CategoryTag> _categories = [];
  final TransactionRepository _repository = TransactionRepository();
  final PlayerRepository _playerRepository = PlayerRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  int _viewMode = 0; // 0:履歴, 1:分析

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allItems = await _repository.getAllTransactions();
    final cats = await _categoryRepository.getCategories();

    setState(() {
      _history = allItems.where((i) {
        return i.date.year == widget.year && i.date.month == widget.month;
      }).toList();
      _categories = cats;
    });
  }

  Future<void> _confirmDelete(TransactionItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除しますか？'),
        content: Text(
          '¥${item.amount} (${item.expense})\n\n※BD(Combat Power)は返却されませんが、トップ画面の支出合計からは減算されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteItem(item);
    }
  }

  Future<void> _deleteItem(TransactionItem item) async {
    // 1. 履歴から削除
    await _repository.deleteTransaction(item);
    // 2. 支出額を減算（返金）
    await _playerRepository.refundRealSpending(item.amount);
    // 3. リスト更新
    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('削除しました')));
  }

  @override
  Widget build(BuildContext context) {
    int total = _history.fold(0, (s, i) => s + i.amount);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "${widget.year}年 ${widget.month}月",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildSummaryCard(total),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _buildSwitchButton('履歴', 0),
              _buildSwitchButton('分析', 1),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _viewMode == 0
              ? _buildHistoryList()
              : _buildAnalysisView(total),
        ),
      ],
    );
  }

  Widget _buildSwitchButton(String label, int index) {
    final isSelected = _viewMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [const BoxShadow(color: Colors.black12, blurRadius: 2)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return const Center(
        child: Text('データがありません', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: _history.length,
      itemBuilder: (c, i) {
        final item = _history[i];
        final expenseStr =
            (item.expense == 'デフォルト' || item.expense == 'Daily Damage')
            ? ''
            : ' (${item.expense})';
        return ListTile(
          title: Text('¥${item.amount}$expenseStr'),
          subtitle: Text(item.displayDate),
          onLongPress: () => _confirmDelete(item),
        );
      },
    );
  }

  Widget _buildAnalysisView(int totalAmount) {
    if (totalAmount == 0) {
      return const Center(
        child: Text('データがありません', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '費目別',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ..._buildRankList(total: totalAmount),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  List<Widget> _buildRankList({required int total}) {
    Map<String, int> sums = {};
    for (var item in _history) {
      final key = item.expense;
      sums[key] = (sums[key] ?? 0) + item.amount;
    }

    final sortedKeys = sums.keys.toList()
      ..sort((a, b) => sums[b]!.compareTo(sums[a]!));

    return sortedKeys.map((key) {
      final amount = sums[key]!;
      final percent = (amount / total);

      // 色の決定ロジック
      Color color = Colors.blueGrey; // デフォルト色
      try {
        color = _categories.firstWhere((t) => t.label == key).color;
      } catch (_) {
        // カスタムカテゴリに見つからない場合（Daily Damageなど）はデフォルト色のまま
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text('¥$amount'),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSummaryCard(int total) {
    return Card(
      margin: const EdgeInsets.all(15),
      color: Colors.blue.shade50,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('総支出', style: TextStyle(color: Colors.blueGrey)),
            Text(
              '¥ $total',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
