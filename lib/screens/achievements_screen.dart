import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement.dart';
import '../repositories/player_repository.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final PlayerRepository _repository = PlayerRepository();
  List<String> _unlockedIds = [];
  int _inputCount = 0;
  int _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await _repository.getPlayerStats();
    // もしここでエラーが出る場合は、手順1のメソッドをPlayerRepositoryに追加してください
    final ids = await _repository.getUnlockedAchievementIds();

    setState(() {
      _inputCount = stats['inputCount'];
      // 【修正箇所】 totalAmount ではなく cp (Combat Power) を取得します
      _totalAmount = stats['cp'] ?? 0;
      _unlockedIds = ids;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 解除率計算
    final progress = _unlockedIds.length / allAchievements.length;

    return Scaffold(
      backgroundColor: const Color(0xFF111122),
      appBar: AppBar(
        title: Text(
          'TROPHY ROOM',
          style: GoogleFonts.pressStart2p(fontSize: 16),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ヘッダー部分（進捗表示）
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(bottom: BorderSide(color: Colors.cyan, width: 2)),
            ),
            child: Row(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade800,
                  color: Colors.cyanAccent,
                  strokeWidth: 8,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNLOCK PROGRESS',
                      style: GoogleFonts.vt323(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}% COMPLETE',
                      style: GoogleFonts.orbitron(
                        color: Colors.cyanAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'TOTAL HITS: $_inputCount / TOTAL DMG: ¥$_totalAmount',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 実績リスト
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: allAchievements.length,
              itemBuilder: (context, index) {
                final item = allAchievements[index];
                final isUnlocked = _unlockedIds.contains(item.id);

                return _buildAchievementTile(item, isUnlocked);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Achievement item, bool isUnlocked) {
    final color = isUnlocked ? Colors.cyanAccent : Colors.grey;
    final bgColor = isUnlocked
        ? Colors.cyan.withOpacity(0.1)
        : Colors.white.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked ? Colors.cyan.withOpacity(0.5) : Colors.white10,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5)),
            boxShadow: isUnlocked
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)]
                : [],
          ),
          child: Icon(
            isUnlocked ? item.icon : Icons.lock,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          isUnlocked ? item.title : '???',
          style: GoogleFonts.pressStart2p(
            color: isUnlocked ? Colors.white : Colors.white38,
            fontSize: 10,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              isUnlocked ? item.description : 'Unlock condition hidden',
              style: GoogleFonts.vt323(
                color: isUnlocked ? Colors.white70 : Colors.white24,
                fontSize: 16,
              ),
            ),
            if (!isUnlocked)
              Text(
                item.type == AchievementType.inputCount
                    ? 'Hint: Keep attacking... (${item.threshold} hits)'
                    : 'Hint: Increase damage... (¥${item.threshold})',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }
}
