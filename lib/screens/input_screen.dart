import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/kakeibo_game.dart';
import '../models/category_tag.dart';
import '../models/transaction_item.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/player_repository.dart';
import '../widgets/category_selector.dart';
import '../widgets/app_drawer.dart';
import '../widgets/number_keypad.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TransactionRepository _repository = TransactionRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();
  final PlayerRepository _playerRepository = PlayerRepository();

  final KakeiboGame _game = KakeiboGame();

  List<ShortcutItem> _shortcuts = [];
  int? _selectedExpenseIndex;
  int? _selectedPaymentIndex;
  DateTime _selectedDate = DateTime.now();
  String _currentMemo = '';

  // ステータス関連
  int _totalCombatPower = 0;
  int _currentLevel = 1;
  double _xpProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadShortcuts();
    _loadDefaultPayment();
    _loadPlayerStats();
  }

  Future<void> _loadShortcuts() async {
    final items = await _settingsRepository.getActiveShortcuts();
    setState(() => _shortcuts = items);
  }

  Future<void> _loadDefaultPayment() async {
    final defaultLabel = await _settingsRepository.loadDefaultPaymentMethod();
    if (defaultLabel != null) {
      final index = paymentTags.indexWhere((tag) => tag.label == defaultLabel);
      if (index != -1) setState(() => _selectedPaymentIndex = index);
    }
  }

  Future<void> _loadPlayerStats() async {
    final score = await _playerRepository.getTotalScore();
    final stats = await _playerRepository.getLevelStats();
    setState(() {
      _totalCombatPower = score;
      _currentLevel = stats['level'];
      _xpProgress = stats['progress'];
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String value) {
    String currentText = _amountController.text;
    if (currentText == '0') currentText = '';
    if (currentText.length >= 9) return;
    setState(() => _amountController.text = currentText + value);
  }

  void _onDelete() {
    String currentText = _amountController.text;
    if (currentText.isNotEmpty) {
      setState(
        () => _amountController.text = currentText.substring(
          0,
          currentText.length - 1,
        ),
      );
    }
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

  Future<void> _showMemoDialog() async {
    final TextEditingController memoController = TextEditingController(
      text: _currentMemo,
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('メモを入力'),
          content: TextField(controller: memoController, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _currentMemo = memoController.text);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeAttack() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty || amountText == "0") return;

    final amount = int.parse(amountText);

    // カテゴリ名の取得
    String categoryName = '未分類';
    if (_selectedExpenseIndex != null) {
      categoryName = expenseTags[_selectedExpenseIndex!].label;
    }

    final newItem = TransactionItem(
      amount: amount,
      expense: categoryName,
      payment: _selectedPaymentIndex != null
          ? paymentTags[_selectedPaymentIndex!].label
          : 'デフォルト',
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
      memo: _currentMemo.isEmpty ? null : _currentMemo,
    );

    await _repository.addTransaction(newItem);
    await _playerRepository.addScore(amount);

    // ゲーム側にカテゴリ名も渡す
    _game.triggerAttack(amount, categoryName);

    // ステータス更新（レベルアップしたかもしれないので）
    await _loadPlayerStats();

    setState(() {
      _amountController.clear();
      _currentMemo = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        onSettingsChanged: () async {
          await _loadShortcuts();
          await _loadDefaultPayment();
        },
      ),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. ゲーム画面（上半分）
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.5,
            child: ClipRect(child: GameWidget(game: _game)),
          ),

          // 2. CP & Level 表示（UI強化）
          // 2. CP & Level 表示（UI強化・オーバーフロー対策済み）
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左側: CP (ExpandedとFittedBoxで、幅が足りない時は文字を小さくする)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TOTAL COMBAT POWER',
                          style: GoogleFonts.pressStart2p(
                            color: Colors.blueAccent,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'CP: $_totalCombatPower',
                          style: GoogleFonts.pressStart2p(
                            color: Colors.white,
                            fontSize: 18,
                            shadows: [
                              const Shadow(color: Colors.blue, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16), // 左右の間に少し隙間を空ける
                // 右側: レベル
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Lv. $_currentLevel',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.yellowAccent,
                        fontSize: 24,
                        shadows: [
                          const Shadow(color: Colors.orange, blurRadius: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 100,
                      height: 8,
                      child: LinearProgressIndicator(
                        value: _xpProgress,
                        backgroundColor: Colors.grey.withOpacity(0.5),
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. コントロールパネル（下半分） - 前回の修正版と同じ
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildStatusDisplay(),

                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          CategorySelector(
                            tags: expenseTags,
                            selectedIndex: _selectedExpenseIndex,
                            rowCount: 1,
                            onSelected: (i) =>
                                setState(() => _selectedExpenseIndex = i),
                          ),
                          const SizedBox(height: 8),
                          CategorySelector(
                            tags: paymentTags,
                            selectedIndex: _selectedPaymentIndex,
                            rowCount: 1,
                            onSelected: (i) =>
                                setState(() => _selectedPaymentIndex = i),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: NumberKeypad(
                              onKeyPressed: _onKeyPressed,
                              onDelete: _onDelete,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                _buildSideButton(
                                  icon: Icons.calendar_today,
                                  label:
                                      "${_selectedDate.month}/${_selectedDate.day}",
                                  color: Colors.orange.shade100,
                                  onTap: _pickDate,
                                ),
                                const SizedBox(height: 8),
                                _buildSideButton(
                                  icon: _currentMemo.isNotEmpty
                                      ? Icons.note
                                      : Icons.note_add_outlined,
                                  label: "MEMO",
                                  color: _currentMemo.isNotEmpty
                                      ? Colors.blue.shade200
                                      : Colors.grey.shade200,
                                  onTap: _showMemoDialog,
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _executeAttack,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.zero,
                                      elevation: 5,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.flash_on, size: 28),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ATTACK',
                                          style: GoogleFonts.pressStart2p(
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 20, // 左からに修正（右だとレベル表示と被るかもなので、メニューは左上にするか、被らないように調整）
            // メニューボタンは邪魔にならない場所に移動しよう
            // 今回はとりあえず放置（右上のままでも、Rowで分けたので大丈夫なはず）
            child: Container(),
          ),
          Positioned(
            top: 100, // 少し下にずらす
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(Icons.menu, color: Colors.black),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'CHARGE: ',
            style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Text(
            _amountController.text.isEmpty ? '0' : _amountController.text,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Text(
            ' G',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
