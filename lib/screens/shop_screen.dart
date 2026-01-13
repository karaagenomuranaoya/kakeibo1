import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shop_item.dart';
import '../repositories/player_repository.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final PlayerRepository _repository = PlayerRepository();
  int _currentCp = 0;
  List<String> _purchasedIds = [];
  String? _equippedSkin;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await _repository.getPlayerStats();
    final purchased = await _repository.getPurchasedItemIds();
    final skin = await _repository.getEquippedSkin();
    setState(() {
      _currentCp = stats['cp'];
      _purchasedIds = purchased;
      _equippedSkin = skin;
    });
  }

  Future<void> _purchase(ShopItem item) async {
    final success = await _repository.purchaseItem(item);
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("TRANSACTION COMPLETE"),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("INSUFFICIENT FUNDS"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _equip(String skinId) async {
    // 既に装備中なら外す（トグル）
    if (_equippedSkin == skinId) {
      await _repository.equipSkin(null);
    } else {
      await _repository.equipSkin(skinId);
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // 深い黒
      appBar: AppBar(
        title: Text(
          'THE DARK WEB',
          style: GoogleFonts.vt323(fontSize: 24, color: Colors.redAccent),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.redAccent),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'CP: $_currentCp',
                style: GoogleFonts.vt323(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: darkWebItems.length,
        itemBuilder: (context, index) {
          final item = darkWebItems[index];
          final isPurchased = _purchasedIds.contains(item.id);
          final isEquipped =
              item.type == ShopItemType.skin &&
              _equippedSkin == item.skinAssetId;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              border: Border.all(
                color: isPurchased
                    ? Colors.grey
                    : Colors.redAccent.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // アイコン
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    item.type == ShopItemType.multiplier
                        ? Icons.bolt
                        : Icons.palette,
                    color: isPurchased ? Colors.grey : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 16),
                // 情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.vt323(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "PRICE: ${item.price} CP",
                        style: GoogleFonts.vt323(
                          color: Colors.yellow,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // ボタン
                if (!isPurchased)
                  ElevatedButton(
                    onPressed: () => _purchase(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("BUY"),
                  )
                else if (item.type == ShopItemType.skin)
                  ElevatedButton(
                    onPressed: () => _equip(item.skinAssetId!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEquipped
                          ? Colors.green
                          : Colors.grey.shade800,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEquipped ? "USED" : "EQUIP"),
                  )
                else
                  const Text(
                    "OWNED",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
