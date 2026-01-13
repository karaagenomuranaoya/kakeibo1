import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/familiar.dart';
import '../repositories/familiar_repository.dart';

class FamiliarScreen extends StatefulWidget {
  const FamiliarScreen({super.key});

  @override
  State<FamiliarScreen> createState() => _FamiliarScreenState();
}

class _FamiliarScreenState extends State<FamiliarScreen>
    with SingleTickerProviderStateMixin {
  final FamiliarRepository _repository = FamiliarRepository();

  int _currentClicks = 0;
  int _requiredClicks = 10;
  List<Familiar> _myCollection = [];
  String? _buddyId; // 現在のバディID

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _loadData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final status = await _repository.getEggStatus();
    final collection = await _repository.getMyCollection();
    final buddy = await _repository.getBuddy();
    setState(() {
      _currentClicks = status['current']!;
      _requiredClicks = status['required']!;
      _myCollection = collection;
      _buddyId = buddy?.id;
    });
  }

  Future<void> _tryHatch() async {
    if (_currentClicks < _requiredClicks) return;

    final newFamiliar = await _repository.hatchEgg();
    if (newFamiliar != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildHatchDialog(newFamiliar),
      );
      _loadData();
    }
  }

  Future<void> _setBuddy(String id) async {
    await _repository.setBuddy(id);
    if (!mounted) return;
    Navigator.pop(context); // ダイアログ閉じる
    _loadData(); // 画面更新

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('BUDDY UPDATED!'),
        backgroundColor: Colors.cyan,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showDetailDialog(Familiar familiar) {
    final isCurrentBuddy = _buddyId == familiar.id;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A12).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: familiar.color, width: 2),
            boxShadow: [
              BoxShadow(color: familiar.color.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "FAMILIAR DATA",
                style: GoogleFonts.orbitron(
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(familiar.emoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 15),
              Text(
                familiar.name,
                style: GoogleFonts.pressStart2p(
                  color: familiar.color,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "★" * familiar.rarity,
                style: const TextStyle(color: Colors.yellow, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // スキル表示エリア
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "SKILL: ${familiar.skillName}",
                      style: GoogleFonts.vt323(
                        color: Colors.cyanAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      familiar.skillDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 説明文
              Text(
                familiar.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 20),

              // ボタン群
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: Text(
                        "CLOSE",
                        style: GoogleFonts.vt323(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isCurrentBuddy
                          ? null
                          : () => _setBuddy(familiar.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentBuddy
                            ? Colors.grey
                            : familiar.color,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        isCurrentBuddy ? "EQUIPPED" : "SET BUDDY",
                        style: GoogleFonts.vt323(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (既存のbuildメソッド内、上部の卵エリアは変更なし) ...
    // 下部のリスト部分のみ変更します

    final progress = (_currentClicks / _requiredClicks).clamp(0.0, 1.0);
    final canHatch = _currentClicks >= _requiredClicks;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: AppBar(
        title: Text('BIO-LAB', style: GoogleFonts.pressStart2p(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'COLLECTION: ${_myCollection.length}/${familiarMasterList.length}',
                style: GoogleFonts.vt323(
                  color: Colors.greenAccent,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 上部：卵（培養槽）エリア (既存コードを流用)
          Container(
            height: 280, // 少し縮める
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.greenAccent, width: 2),
              ),
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF001100)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  canHatch ? "INCUBATION COMPLETE" : "INCUBATING...",
                  style: GoogleFonts.orbitron(
                    color: canHatch ? Colors.redAccent : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: canHatch ? _tryHatch : null,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.95,
                      end: 1.05,
                    ).animate(_pulseController),
                    child: Container(
                      width: 100,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: canHatch
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: canHatch
                                ? Colors.red.withOpacity(0.5)
                                : Colors.green.withOpacity(0.3),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          canHatch ? "!" : "${(progress * 100).toInt()}%",
                          style: GoogleFonts.vt323(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade900,
                        color: canHatch ? Colors.redAccent : Colors.greenAccent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        canHatch
                            ? "TAP EGG TO HATCH!"
                            : "$_currentClicks / $_requiredClicks CLICKS",
                        style: GoogleFonts.vt323(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 下部：コレクションリスト
          Expanded(
            child: _myCollection.isEmpty
                ? Center(
                    child: Text(
                      "NO FAMILIARS FOUND",
                      style: GoogleFonts.vt323(
                        color: Colors.white24,
                        fontSize: 24,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _myCollection.length,
                    itemBuilder: (context, index) {
                      final familiar = _myCollection[index];
                      final isBuddy = _buddyId == familiar.id;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showDetailDialog(familiar),
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isBuddy
                                        ? Colors.yellowAccent
                                        : familiar.color.withOpacity(0.5),
                                    width: isBuddy ? 2 : 1,
                                  ),
                                  boxShadow: isBuddy
                                      ? [
                                          BoxShadow(
                                            color: Colors.yellowAccent
                                                .withOpacity(0.2),
                                            blurRadius: 10,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      familiar.emoji,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      familiar.name,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.vt323(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isBuddy)
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.yellowAccent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "E", // Equipped
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHatchDialog(Familiar familiar) {
    // 既存コードと同じ内容
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: familiar.color, width: 3),
          boxShadow: [
            BoxShadow(color: familiar.color.withOpacity(0.5), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "NEW LIFEFORM DETECTED!",
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(familiar.emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 10),
            Text(
              familiar.name,
              style: GoogleFonts.pressStart2p(
                color: familiar.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: familiar.color,
                foregroundColor: Colors.black,
              ),
              child: const Text("CONFIRM"),
            ),
          ],
        ),
      ),
    );
  }
}
