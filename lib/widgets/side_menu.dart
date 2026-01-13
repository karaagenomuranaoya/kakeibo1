import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onTrophyTap;
  final VoidCallback onEggTap;
  final VoidCallback onShopTap;

  const SideMenu({
    super.key,
    required this.onMenuTap,
    required this.onTrophyTap,
    required this.onEggTap,
    required this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBtn(Icons.menu, Colors.cyanAccent, onMenuTap),
        const SizedBox(height: 15),
        _buildBtn(Icons.emoji_events, Colors.yellowAccent, onTrophyTap),
        const SizedBox(height: 15),
        _buildBtn(Icons.egg, Colors.greenAccent, onEggTap),
        const SizedBox(height: 15),
        _buildBtn(Icons.shopping_cart, Colors.redAccent, onShopTap),
      ],
    );
  }

  Widget _buildBtn(IconData icon, Color color, VoidCallback onTap) {
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
}
