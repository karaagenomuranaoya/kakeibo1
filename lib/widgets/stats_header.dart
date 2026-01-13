import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsHeader extends StatelessWidget {
  final int bd;
  final int realSpending;
  final int level;
  final double xpProgress;

  const StatsHeader({
    super.key,
    required this.bd,
    required this.realSpending,
    required this.level,
    required this.xpProgress,
  });

  // 数値を3桁カンマ区切りの文字列にするヘルパー
  String _format(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'BUDGET DAMAGE',
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
                // ★修正: フォーマット適用
                child: Text(
                  _format(bd),
                  style: GoogleFonts.vt323(
                    color: Colors.white,
                    fontSize: 40,
                    letterSpacing: 2,
                    shadows: [const Shadow(color: Colors.blue, blurRadius: 15)],
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Icon(
                      Icons.currency_yen,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                  // ★修正: フォーマット適用
                  Text(
                    _format(realSpending),
                    style: GoogleFonts.vt323(
                      color: Colors.grey.shade400,
                      fontSize: 24,
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
              'Lv.$level',
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
                value: xpProgress,
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
}
