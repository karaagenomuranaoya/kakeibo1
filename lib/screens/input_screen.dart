import 'dart:math'; // Random用
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/kakeibo_game.dart';
import '../models/category_tag.dart';
import '../models/transaction_item.dart';
import '../models/achievement.dart';
import '../models/familiar.dart'; // Familiar, SkillType
import '../repositories/transaction_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/player_repository.dart';
import '../repositories/familiar_repository.dart';
import '../widgets/category_selector.dart';
import '../widgets/app_drawer.dart';
import '../widgets/number_keypad.dart';
import 'achievements_screen.dart';
import 'familiar_screen.dart';
import 'shop_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});
  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TransactionRepository _repository = TransactionRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();
  final PlayerRepository _playerRepository = PlayerRepository();
  final FamiliarRepository _familiarRepository = FamiliarRepository();

  final KakeiboGame _game = KakeiboGame();

  List<ShortcutItem> _shortcuts = [];
  int? _selectedExpenseIndex;
  DateTime _selectedDate = DateTime.now();
  String _currentMemo = '';

  int _totalCombatPower = 0;
  int _realSpending = 0;
  int _currentLevel = 1;
  double _xpProgress = 0.0;

  double _currentMultiplier = 1.0;
  String? _currentSkin;

  Achievement? _displayingAchievement;
  bool _isAchievementVisible = false;

  Familiar? _currentBuddy;
  late AnimationController _buddyAnimController;
  String? _skillActivationMessage;

  @override
  void initState() {
    super.initState();
    _buddyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadShortcuts();
    _loadPlayerStats();
    _loadShopData();
    _loadBuddy();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _buddyAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadBuddy() async {
    final buddy = await _familiarRepository.getBuddy();
    setState(() => _currentBuddy = buddy);
  }

  Future<void> _loadShortcuts() async {
    final items = await _settingsRepository.getActiveShortcuts();
    setState(() => _shortcuts = items);
  }

  Future<void> _loadPlayerStats() async {
    final stats = await _playerRepository.getPlayerStats();
    setState(() {
      _totalCombatPower = stats['cp'];
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
    String categoryName = '未分類';
    if (_selectedExpenseIndex != null) {
      categoryName = expenseTags[_selectedExpenseIndex!].label;
    }

    final newItem = TransactionItem(
      amount: amount,
      expense: categoryName,
      payment: 'Default',
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

    double skillMultiplier = 1.0;
    String? activationText;

    if (_currentBuddy != null) {
      final nowHour = DateTime.now().hour;
      final rnd = Random().nextDouble();

      switch (_currentBuddy!.skillType) {
        case SkillType.lowCostBonus:
          if (amount <= 1000) {
            skillMultiplier = 1.5;
            activationText = "MICRO SAVER ACTIVATED! (x1.5)";
          }
          break;
        case SkillType.nightBonus:
          if (nowHour >= 18 || nowHour < 6) {
            skillMultiplier = 1.5;
            activationText = "NIGHT WALKER ACTIVATED! (x1.5)";
          }
          break;
        case SkillType.randomCritical:
          if (_currentBuddy!.id == 'crypto_dragon') {
            if (rnd < 0.05) {
              skillMultiplier = 10.0;
              activationText = "TO THE MOON!!! (x10.0)";
            }
          } else if (_currentBuddy!.id == 'cyber_wolf') {
            if (rnd < 0.20) {
              skillMultiplier = 3.0;
              activationText = "CRITICAL FANG! (x3.0)";
            }
          } else {
            if (rnd < 0.50) {
              skillMultiplier = 2.0;
              activationText = "LUCKY GLITCH! (x2.0)";
            }
          }
          break;
        case SkillType.passiveBoost:
          if (_currentBuddy!.id == 'singularity_eye') {
            skillMultiplier = 3.0;
            activationText = "SINGULARITY POWER (x3.0)";
          } else if (_currentBuddy!.id == 'code_spider') {
            skillMultiplier = 1.2;
            activationText = "WEB BOOST (x1.2)";
          } else {
            skillMultiplier = 1.1;
            activationText = "PASSIVE BOOST (x1.1)";
          }
          break;
        case SkillType.highRoller:
          if (amount >= 5000) {
            skillMultiplier = 2.5;
            activationText = "HIGH ROLLER! (x2.5)";
          }
          break;
        default:
          break;
      }
    }

    double finalMultiplier = _currentMultiplier * skillMultiplier;
    int gainedCp = (amount * finalMultiplier).toInt();

    if (activationText != null) {
      setState(() => _skillActivationMessage = activationText);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _skillActivationMessage = null);
      });
    }

    final unlockedAchievements = await _playerRepository.addTransactionData(
      realAmount: amount,
      gainedCp: gainedCp,
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
        onSettingsChanged: () async {
          await _loadShortcuts();
        },
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

          // 2. Stats
          Positioned(top: 50, left: 20, right: 20, child: _buildStatsHeader()),

          // 3. Buddy
          if (_currentBuddy != null)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.55 + 10,
              right: 20,
              child: AnimatedBuilder(
                animation: _buddyAnimController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _buddyAnimController.value * 10),
                    child: Column(
                      children: [
                        if (_skillActivationMessage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              border: Border.all(color: Colors.yellowAccent),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _skillActivationMessage!,
                              style: GoogleFonts.vt323(
                                color: Colors.yellowAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _currentBuddy!.color.withOpacity(0.3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Text(
                            _currentBuddy!.emoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
                  _buildStatusDisplay(),
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
                          CategorySelector(
                            tags: expenseTags,
                            selectedIndex: _selectedExpenseIndex,
                            rowCount: 1,
                            onSelected: (i) =>
                                setState(() => _selectedExpenseIndex = i),
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
                                _buildSideButton(
                                  icon: Icons.calendar_today,
                                  label:
                                      "${_selectedDate.month}/${_selectedDate.day}",
                                  color: Colors.orangeAccent.withOpacity(0.2),
                                  textColor: Colors.orangeAccent,
                                  onTap: _pickDate,
                                ),
                                const SizedBox(height: 10),
                                _buildSideButton(
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF4444),
                                          Color(0xFF990000),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withOpacity(
                                            0.5,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.redAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: _executeAttack,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.flash_on,
                                                  size: 30,
                                                  color: Colors.white,
                                                ), // サイズ微調整 36->30
                                                const SizedBox(
                                                  height: 2,
                                                ), // 4->2
                                                Text(
                                                  'ATTACK',
                                                  style:
                                                      GoogleFonts.pressStart2p(
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
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

          // 5. Right Menu
          Positioned(
            top: 100,
            right: 20,
            child: Column(
              children: [
                _buildSquareIconButton(
                  icon: Icons.menu,
                  color: Colors.cyanAccent,
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(height: 15),
                _buildSquareIconButton(
                  icon: Icons.emoji_events,
                  color: Colors.yellowAccent,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    );
                    _loadPlayerStats();
                  },
                ),
                const SizedBox(height: 15),
                _buildSquareIconButton(
                  icon: Icons.egg,
                  color: Colors.greenAccent,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FamiliarScreen(),
                      ),
                    );
                    _loadBuddy();
                  },
                ),
                const SizedBox(height: 15),
                _buildSquareIconButton(
                  icon: Icons.shopping_cart,
                  color: Colors.redAccent,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShopScreen(),
                      ),
                    );
                    _loadPlayerStats();
                    _loadShopData();
                  },
                ),
              ],
            ),
          ),

          // 6. Achievement Popup
          Positioned(
            right: 75,
            top: 220,
            child: AnimatedOpacity(
              opacity: _isAchievementVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _displayingAchievement != null
                  ? Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.yellowAccent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.yellowAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "UNLOCKED!",
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 10,
                                  color: Colors.yellow,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _displayingAchievement!.title,
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'COMBAT POWER',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.cyanAccent,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$_totalCombatPower',
                  style: GoogleFonts.vt323(
                    color: Colors.white,
                    fontSize: 40,
                    letterSpacing: 2,
                    shadows: [const Shadow(color: Colors.blue, blurRadius: 15)],
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.currency_yen,
                    color: Colors.grey.shade600,
                    size: 12,
                  ),
                  Text(
                    "$_realSpending",
                    style: GoogleFonts.vt323(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Lv.$_currentLevel',
              style: GoogleFonts.pressStart2p(
                color: Colors.yellowAccent,
                fontSize: 20,
                shadows: [const Shadow(color: Colors.orange, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 100,
              height: 6,
              child: LinearProgressIndicator(
                value: _xpProgress,
                backgroundColor: Colors.grey.withOpacity(0.3),
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSquareIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.8)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: color),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildStatusDisplay() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'CHARGE MODE',
            style: GoogleFonts.vt323(fontSize: 18, color: Colors.greenAccent),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _amountController.text.isEmpty ? '0' : _amountController.text,
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                  shadows: [const Shadow(color: Colors.cyan, blurRadius: 10)],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'G',
                style: GoogleFonts.pressStart2p(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8), // 10 -> 8 に縮小
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: textColor.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.vt323(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
