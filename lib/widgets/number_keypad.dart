import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;

  const NumberKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 背景色削除（親側で管理）
      padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['7', '8', '9']),
          _buildRow(['4', '5', '6']),
          _buildRow(['1', '2', '3']),
          _buildRow(['00', '0', 'DEL']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildButton(key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String key) {
    final isDelete = key == 'DEL';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (isDelete) {
            onDelete();
          } else {
            onKeyPressed(key);
          }
        },
        // ボタンのデザイン: 半透明の黒背景 + ネオンボーダー
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05), // うっすら明るく
            border: Border.all(
              color: isDelete
                  ? Colors.redAccent.withOpacity(0.3)
                  : Colors.cyanAccent.withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              // 押せる感じの影（内側）
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 2,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: isDelete
                ? const Icon(
                    Icons.backspace_outlined,
                    color: Colors.redAccent,
                    size: 24,
                  )
                : Text(
                    key,
                    style: GoogleFonts.orbitron(
                      // SFチックな数字フォント
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      shadows: [
                        const Shadow(color: Colors.blue, blurRadius: 5),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
