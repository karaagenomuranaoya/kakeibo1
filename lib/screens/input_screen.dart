import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';

// Game & Models
import '../game/kakeibo_game.dart';
import '../models/category_tag.dart';
import '../models/transaction_item.dart';
import '../models/achievement.dart';
import '../models/familiar.dart';

// Repositories & Services
import '../repositories/transaction_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/familiar_repository.dart';
import '../repositories/category_repository.dart';
import '../services/familiar_service.dart';

// Widgets
import '../widgets/category_selector.dart';
import '../widgets/app_drawer.dart';
import '../widgets/number_keypad.dart';
import '../widgets/stats_header.dart';
import '../widgets/buddy_display.dart';
import '../widgets/side_menu.dart';
import '../widgets/status_display.dart';
import '../widgets/side_action_button.dart';
import '../widgets/attack_button.dart';
import '../widgets/achievement_popup.dart';

// Screens
import 'achievements_screen.dart';
import 'familiar_screen.dart';
import 'shop_screen.dart';

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
  final FamiliarRepository _familiarRepository = FamiliarRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final FamiliarService _familiarService = FamiliarService();

  final KakeiboGame _game = KakeiboGame();

  List<CategoryTag> _categories = [];

  // 設定値
  bool _allowEmptyCategory = true;
  String _defaultCategoryName = 'Daily Damage';

  int? _selectedExpenseIndex;
  DateTime _selectedDate = DateTime.now();
  String _currentMemo = '';

  int _totalBudgetDamage = 0;
  int _realSpending = 0;
  int _currentLevel = 1;
  double _xpProgress = 0.0;

  double _currentMultiplier = 1.0;
  String? _currentSkin;

  Achievement? _displayingAchievement;
  bool _isAchievementVisible = false;

  Familiar? _currentBuddy;
  String? _skillActivationMessage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadCategoriesAndSettings(),
      _loadPlayerStats(),
      _loadShopData(),
      _loadBuddy(),
    ]);
  }

  Future<void> _loadBuddy() async {
    final buddy = await _familiarRepository.getBuddy();
    setState(() => _currentBuddy = buddy);
  }

  Future<void> _loadCategoriesAndSettings() async {
    final items = await _categoryRepository.getCategories();
    final allow = await _settingsRepository.getAllowEmptyCategory();
    final defName = await _settingsRepository.getDefaultCategoryName();

    setState(() {
      _categories = items;
      _allowEmptyCategory = allow;
      _defaultCategoryName = defName;
    });
  }

  Future<void> _loadPlayerStats() async {
    final stats = await _playerRepository.getPlayerStats();
    setState(() {
      _totalBudgetDamage = stats['bd'];
      _realSpending = stats['realSpending'];
      _currentLevel = stats['level'];
      _xpProgress = stats['progress'];
    });
  }

  Future<void> _loadShopData() async {
    final mult = await _playerRepository.getCurrentMultiplier();
    final skin = await _playerRepository.getEquippedSkin();
    setState(() {
      _currentMultiplier = mult;
      _currentSkin = skin;
    });
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
          backgroundColor: const Color(0xFF222244),
          title: Text(
            'MEMO INPUT',
            style: GoogleFonts.vt323(color: Colors.cyanAccent, fontSize: 24),
          ),
          content: TextField(
            controller: memoController,
            style: const TextStyle(color: Colors.white),
            autofocus: true,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() => _currentMemo = memoController.text);
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.cyanAccent),
              ),
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

    String categoryName = '';

    if (_selectedExpenseIndex != null &&
        _selectedExpenseIndex! < _categories.length) {
      categoryName = _categories[_selectedExpenseIndex!].label;
    } else {
      if (!_allowEmptyCategory) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ターゲットクラス（カテゴリ）を選択してください！'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      categoryName = _defaultCategoryName;
    }

    // 1. 保存処理
    final newItem = TransactionItem(
      amount: amount,
      expense: categoryName,
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

    // 2. スキル計算
    final skillResult = _familiarService.calculateSkillBonus(
      _currentBuddy,
      amount,
    );

    double finalMultiplier = _currentMultiplier * skillResult.multiplier;
    int gainedBd = (amount * finalMultiplier).toInt();

    // 3. UIへのフィードバック
    if (skillResult.activationMessage != null) {
      setState(() => _skillActivationMessage = skillResult.activationMessage);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _skillActivationMessage = null);
      });
    }

    // 4. プレイヤー更新
    final unlockedAchievements = await _playerRepository.addTransactionData(
      realAmount: amount,
      gainedBd: gainedBd,
    );

    if (unlockedAchievements.isNotEmpty) {
      _triggerAchievementPopup(unlockedAchievements);
    }

    await _familiarRepository.addEggClick();
    _game.triggerAttack(amount, categoryName, _currentSkin);
    await _loadPlayerStats();

    setState(() {
      _amountController.clear();
      _currentMemo = '';
    });
  }

  Future<void> _triggerAchievementPopup(List<Achievement> achievements) async {
    for (var item in achievements) {
      if (!mounted) return;
      setState(() {
        _displayingAchievement = item;
        _isAchievementVisible = true;
      });
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _isAchievementVisible = false;
      });
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        onSettingsChanged: _loadCategoriesAndSettings,
        onReportClosed: _loadPlayerStats,
      ),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Game Screen
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.4,
            child: ClipRect(child: GameWidget(game: _game)),
          ),

          // 2. Stats Header
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: StatsHeader(
              bd: _totalBudgetDamage,
              realSpending: _realSpending,
              level: _currentLevel,
              xpProgress: _xpProgress,
            ),
          ),

          // 3. Buddy Display
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.55 + 10,
            right: 20,
            child: BuddyDisplay(
              buddy: _currentBuddy,
              message: _skillActivationMessage,
            ),
          ),

          // 4. Cockpit (Bottom Half)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                color: const Color(0xFF111122),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: const Border(
                  top: BorderSide(color: Colors.cyan, width: 2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  StatusDisplay(amountText: _amountController.text),

                  if (_currentBuddy != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      color: _currentBuddy!.color.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: _currentBuddy!.color,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "BUDDY SYSTEM: ${_currentBuddy!.name} [${_currentBuddy!.skillName}]",
                            style: GoogleFonts.vt323(
                              color: _currentBuddy!.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TARGET CLASS",
                            style: GoogleFonts.pressStart2p(
                              color: Colors.grey,
                              fontSize: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // ★修正: 再タップで選択解除ロジックを追加
                          CategorySelector(
                            tags: _categories,
                            selectedIndex: _selectedExpenseIndex,
                            rowCount: 1,
                            onSelected: (i) => setState(() {
                              if (_selectedExpenseIndex == i) {
                                _selectedExpenseIndex = null;
                              } else {
                                _selectedExpenseIndex = i;
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                SideActionButton(
                                  icon: Icons.calendar_today,
                                  label:
                                      "${_selectedDate.month}/${_selectedDate.day}",
                                  color: Colors.orangeAccent.withOpacity(0.2),
                                  textColor: Colors.orangeAccent,
                                  onTap: _pickDate,
                                ),
                                const SizedBox(height: 10),
                                SideActionButton(
                                  icon: _currentMemo.isNotEmpty
                                      ? Icons.note
                                      : Icons.note_add_outlined,
                                  label: "MEMO",
                                  color: _currentMemo.isNotEmpty
                                      ? Colors.cyan.withOpacity(0.4)
                                      : Colors.white10,
                                  textColor: _currentMemo.isNotEmpty
                                      ? Colors.cyanAccent
                                      : Colors.grey,
                                  onTap: _showMemoDialog,
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: AttackButton(onTap: _executeAttack),
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

          // 5. Right Menu
          Positioned(
            top: 100,
            right: 20,
            child: SideMenu(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onTrophyTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AchievementsScreen(),
                  ),
                );
                _loadPlayerStats();
              },
              onEggTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FamiliarScreen(),
                  ),
                );
                _loadBuddy();
              },
              onShopTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopScreen()),
                );
                _loadPlayerStats();
                _loadShopData();
              },
            ),
          ),

          // 6. Achievement Popup
          Positioned(
            right: 75,
            top: 220,
            child: AchievementPopup(
              achievement: _displayingAchievement,
              isVisible: _isAchievementVisible,
            ),
          ),
        ],
      ),
    );
  }
}
