import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/familiar.dart';

class BuddyDisplay extends StatefulWidget {
  final Familiar? buddy;
  final String? message;

  const BuddyDisplay({super.key, this.buddy, this.message});

  @override
  State<BuddyDisplay> createState() => _BuddyDisplayState();
}

class _BuddyDisplayState extends State<BuddyDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buddy == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _controller.value * 10), // ふわふわ
          child: Column(
            children: [
              // メッセージ (スキル発動時など)
              if (widget.message != null)
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
                    widget.message!,
                    style: GoogleFonts.vt323(
                      color: Colors.yellowAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // キャラ本体
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.buddy!.color.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Text(
                  widget.buddy!.emoji,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
