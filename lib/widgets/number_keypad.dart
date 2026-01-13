import 'package:flutter/material.dart';

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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20), // 下に余白
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
              padding: const EdgeInsets.all(4.0), // ボタン間の隙間
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
      color: isDelete ? Colors.red.shade50 : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (isDelete) {
            onDelete();
          } else {
            onKeyPressed(key);
          }
        },
        child: Center(
          child: isDelete
              ? const Icon(Icons.backspace_outlined, color: Colors.redAccent)
              : Text(
                  key,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }
}
