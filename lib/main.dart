import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const QuickKakeiboApp());
}

// --- データモデル ---
class CategoryTag {
  final String label;
  final Color color;
  final bool isCircle;
  CategoryTag(this.label, this.color, {this.isCircle = false});
}

// --- 定数データ ---
final List<CategoryTag> expenseTags = [
  CategoryTag('食費', Colors.orange, isCircle: true),
  CategoryTag('日用品', Colors.green, isCircle: true),
  CategoryTag('雑費', Colors.blueGrey, isCircle: true),
  CategoryTag('交際費', Colors.pink, isCircle: true),
  CategoryTag('趣味', Colors.purple, isCircle: true),
];

final List<CategoryTag> paymentTags = [
  CategoryTag('現金', Colors.grey),
  CategoryTag('クレカ', Colors.blue),
  CategoryTag('PayPay', Colors.redAccent),
  CategoryTag('Suica', Colors.lightGreen),
];

// --- メインアプリ ---
class QuickKakeiboApp extends StatelessWidget {
  const QuickKakeiboApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const InputScreen(),
    );
  }
}

// --- 入力画面 ---
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int? _selectedExpenseIndex;
  int? _selectedPaymentIndex;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // タグ選択用ウィジェットビルダー
  Widget _buildTagSelector({
    required List<CategoryTag> tags,
    required int? selectedIndex,
    required int rowCount,
    required Function(int) onSelected,
  }) {
    return SizedBox(
      height: rowCount == 2 ? 100 : 50,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rowCount,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: rowCount == 2 ? 0.45 : 0.4,
        ),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedIndex == index;
          return ChoiceChip(
            label: Text(tag.label, style: const TextStyle(fontSize: 12)),
            selected: isSelected,
            onSelected: (_) => onSelected(index),
            shape: tag.isCircle
                ? const StadiumBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
            selectedColor: tag.color.withOpacity(0.3),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  // 保存処理
  Future<void> _saveData({required bool shouldDismissKeyboard}) async {
    final amountText = _amountController.text;
    if (amountText.isEmpty || amountText == "0") {
      if (shouldDismissKeyboard) _amountFocusNode.unfocus();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> history = json.decode(prefs.getString('history') ?? '[]');
    final finalDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
    );

    history.insert(0, {
      'amount': int.tryParse(amountText) ?? 0,
      'expense': _selectedExpenseIndex != null
          ? expenseTags[_selectedExpenseIndex!].label
          : '未分類',
      'payment': _selectedPaymentIndex != null
          ? paymentTags[_selectedPaymentIndex!].label
          : '現金',
      'date_iso': finalDate.toIso8601String(),
      'display_date':
          "${finalDate.month}/${finalDate.day} ${finalDate.hour}:${finalDate.minute.toString().padLeft(2, '0')}",
    });
    await prefs.setString('history', json.encode(history));
    setState(() {
      _amountController.clear();
      _selectedExpenseIndex = null;
      _selectedPaymentIndex = null;
    });
    if (shouldDismissKeyboard) _amountFocusNode.unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('保存しました'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // メニューが開いた瞬間にキーボードを閉じる
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          _amountFocusNode.unfocus();
        }
      },
      drawer: _buildDrawer(),
      // 背景タップでキーボードを閉じる
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                    child: Column(
                      children: [
                        // 金額入力エリア
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 常に表示される円マーク
                            const Text(
                              '¥ ',
                              style: TextStyle(
                                fontSize: 44,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                focusNode: _amountFocusNode,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black12,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // 日付選択ボタン
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: IconButton(
                                onPressed: _pickDate,
                                icon: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${_selectedDate.month}/${_selectedDate.day}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // 費目タグ
                        _buildTagSelector(
                          tags: expenseTags,
                          selectedIndex: _selectedExpenseIndex,
                          rowCount: 2,
                          onSelected: (i) =>
                              setState(() => _selectedExpenseIndex = i),
                        ),
                        // 区切り線
                        const Divider(
                          height: 30,
                          thickness: 1,
                          color: Colors.black12,
                        ),
                        // 支払い方法タグ
                        _buildTagSelector(
                          tags: paymentTags,
                          selectedIndex: _selectedPaymentIndex,
                          rowCount: 2,
                          onSelected: (i) =>
                              setState(() => _selectedPaymentIndex = i),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // 下部アクションボタン
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _saveData(shouldDismissKeyboard: false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('次へ'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _saveData(shouldDismissKeyboard: true),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('完了'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 左上メニューボタン（フローティング）
            Positioned(
              top: 45,
              left: 15,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.blue, size: 24),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // サイドメニュー（ドロワー）
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'メニュー',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('月別レポート'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthlyHistoryScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
            child: Text(
              "費目別",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          ...expenseTags.map(
            (tag) => ListTile(
              leading: Icon(Icons.label, color: tag.color),
              title: Text(tag.label),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(
                      filterValue: tag.label,
                      filterKey: 'expense',
                      color: tag.color,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
            child: Text(
              "支払い方法別",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          ...paymentTags.map(
            (tag) => ListTile(
              leading: Icon(Icons.payment, color: tag.color),
              title: Text(tag.label),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(
                      filterValue: tag.label,
                      filterKey: 'payment',
                      color: tag.color,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- 月別レポート画面 ---
class MonthlyHistoryScreen extends StatefulWidget {
  const MonthlyHistoryScreen({super.key});
  @override
  State<MonthlyHistoryScreen> createState() => _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends State<MonthlyHistoryScreen> {
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1000);
  }

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

// --- 特定月の表示 ---
class MonthPage extends StatefulWidget {
  final int year;
  final int month;
  const MonthPage({super.key, required this.year, required this.month});
  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  List<dynamic> _history = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> all = json.decode(prefs.getString('history') ?? '[]');
    setState(
      () => _history = all.where((i) {
        final d = DateTime.parse(i['date_iso']);
        return d.year == widget.year && d.month == widget.month;
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = _history.fold(0, (s, i) => s + (i['amount'] as int));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "${widget.year}年 ${widget.month}月",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: const EdgeInsets.all(15),
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  '¥ $total',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Wrap(
                  spacing: 10,
                  children: expenseTags.map((t) {
                    int s = _history
                        .where((i) => i['expense'] == t.label)
                        .fold(0, (sum, i) => sum + (i['amount'] as int));
                    return s > 0
                        ? Text(
                            '${t.label}: ¥$s',
                            style: TextStyle(
                              color: t.color,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink();
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _history.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(
                '¥${_history[i]['amount']} (${_history[i]['expense']})',
              ),
              subtitle: Text(
                '${_history[i]['payment']} / ${_history[i]['display_date']}',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- 特定タグ/支払い方法 履歴画面 ---
class HistoryScreen extends StatefulWidget {
  final String filterValue;
  final String filterKey;
  final Color? color;

  const HistoryScreen({
    super.key,
    required this.filterValue,
    required this.filterKey,
    this.color,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> all = json.decode(prefs.getString('history') ?? '[]');
    setState(
      () => _history = all
          .where((i) => i[widget.filterKey] == widget.filterValue)
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = _history.fold(0, (s, i) => s + (i['amount'] as int));
    return Scaffold(
      appBar: AppBar(title: Text(widget.filterValue)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: widget.color?.withOpacity(0.1) ?? Colors.blue.shade50,
            child: Center(
              child: Column(
                children: [
                  Text(
                    widget.filterKey == 'expense' ? '費目累計' : '支払い累計',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '¥ $total',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.color ?? Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (c, i) => ListTile(
                leading: widget.filterKey == 'payment'
                    ? Icon(Icons.payment, color: widget.color)
                    : Icon(Icons.label, color: widget.color),
                title: Text(
                  '¥${_history[i]['amount']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${_history[i]['display_date']}  /  ${widget.filterKey == 'expense' ? _history[i]['payment'] : _history[i]['expense']}",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
