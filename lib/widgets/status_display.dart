import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusDisplay extends StatelessWidget {
  final String amountText;

  const StatusDisplay({super.key, required this.amountText});

  @override
  Widget build(BuildContext context) {
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
                amountText.isEmpty ? '0' : amountText,
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
}
