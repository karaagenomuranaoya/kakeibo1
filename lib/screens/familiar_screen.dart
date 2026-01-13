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
    setState(() {
      _currentClicks = status['current']!;
      _requiredClicks = status['required']!;
      _myCollection = collection;
    });
  }

  Future<void> _tryHatch() async {
    if (_currentClicks < _requiredClicks) return;

    final newFamiliar = await _repository.hatchEgg();
    if (newFamiliar != null) {
      if (!mounted) return;
      // 孵化演出ダイアログ
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildHatchDialog(newFamiliar),
      );
      _loadData(); // データ更新
    }
  }

  // ★★★ 新規追加: 詳細閲覧ダイアログ ★★★
  void _showDetailDialog(Familiar familiar) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A12).withOpacity(0.95), // 背景を少し透過させてサイバー感
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: familiar.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: familiar.color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
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

              // アイコン
              Text(familiar.emoji, style: const TextStyle(fontSize: 80)),

              const SizedBox(height: 15),

              // 名前
              Text(
                familiar.name,
                style: GoogleFonts.pressStart2p(
                  color: familiar.color,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // レアリティ
              Text(
                "★" * familiar.rarity,
                style: const TextStyle(color: Colors.yellow, fontSize: 14),
              ),

              const SizedBox(height: 20),

              // 説明文エリア
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  familiar.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vt323(color: Colors.white, fontSize: 20),
                ),
              ),

              const SizedBox(height: 20),

              // 閉じるボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "CLOSE",
                    style: GoogleFonts.vt323(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // 上部：卵（培養槽）エリア
          Container(
            height: 300,
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

                // 卵本体
                GestureDetector(
                  onTap: canHatch ? _tryHatch : null,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.95,
                      end: 1.05,
                    ).animate(_pulseController),
                    child: Container(
                      width: 120,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(60),
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
                            spreadRadius: 5,
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

                const SizedBox(height: 30),

                // プログレスバー
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade900,
                        color: canHatch ? Colors.redAccent : Colors.greenAccent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        canHatch
                            ? "TAP EGG TO HATCH!"
                            : "DATA INPUT REQUIRED: $_currentClicks / $_requiredClicks",
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

          // 下部：コレクションリスト（修正済み）
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
                      // ★★★ InkWellでラップしてタップ可能にする ★★★
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showDetailDialog(familiar), // タップで詳細表示
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: familiar.color.withOpacity(0.5),
                              ),
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
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "★" * familiar.rarity,
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
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
            const SizedBox(height: 5),
            Text(
              "★" * familiar.rarity,
              style: const TextStyle(color: Colors.yellow, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              familiar.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
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
