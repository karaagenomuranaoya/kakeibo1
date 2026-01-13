import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsHeader extends StatelessWidget {
  final int cp;
  final int realSpending;
  final int level;
  final double xpProgress;

  const StatsHeader({
    super.key,
    required this.cp,
    required this.realSpending,
    required this.level,
    required this.xpProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CP & Spending
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
                  '$cp',
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
                    "$realSpending",
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
        // Level & Bar
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
