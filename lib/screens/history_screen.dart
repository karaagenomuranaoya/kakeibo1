import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../repositories/transaction_repository.dart';

class HistoryScreen extends StatefulWidget {
  final String filterValue;
  final Color? color;

  const HistoryScreen({super.key, required this.filterValue, this.color});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransactionItem> _allHistory = [];
  final TransactionRepository _repository = TransactionRepository();

  final PageController _pageController = PageController(initialPage: 1000);
  int _currentPage = 1000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allItems = await _repository.getAllTransactions();
    setState(() {
      _allHistory = allItems.where((i) {
        // 単純に費目(expense)でフィルタリング
        return i.expense == widget.filterValue;
      }).toList();
    });
  }

  DateTime _getDateForPage(int page) {
    final now = DateTime.now();
    return DateTime(now.year, now.month + (page - 1000));
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthDate = _getDateForPage(_currentPage);

    return Scaffold(
      appBar: AppBar(title: Text(widget.filterValue), centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "${currentMonthDate.year}年 ${currentMonthDate.month}月",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildMonthContent(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthContent(int pageIndex) {
    final date = _getDateForPage(pageIndex);
    final monthData = _allHistory.where((i) {
      return i.date.year == date.year && i.date.month == date.month;
    }).toList();

    int total = monthData.fold(0, (s, i) => s + i.amount);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          color: widget.color?.withOpacity(0.1) ?? Colors.blue.shade50,
          child: Center(
            child: Column(
              children: [
                Text(
                  '${date.month}月の合計',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '¥ $total',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.color ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: monthData.isEmpty
              ? const Center(
                  child: Text('履歴はありません', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: monthData.length,
                  itemBuilder: (c, i) {
                    final item = monthData[i];
                    return ListTile(
                      leading: Icon(Icons.label, color: widget.color),
                      title: Row(
                        children: [
                          Text(
                            '¥${item.amount}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (item.memo != null && item.memo!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.note,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.displayDate),
                          if (item.memo != null && item.memo!.isNotEmpty)
                            Text(
                              item.memo!,
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
