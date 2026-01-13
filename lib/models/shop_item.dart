enum ShopItemType {
  multiplier, // 倍率アップ（インフレ）
  skin, // 見た目変更
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final ShopItemType type;
  final double? effectValue; // 倍率加算値など
  final String? skinAssetId; // スキン用ID

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    this.effectValue,
    this.skinAssetId,
  });
}

// 闇市の商品リスト
final List<ShopItem> darkWebItems = [
  // --- インフレ加速装置 (Multiplier) ---
  const ShopItem(
    id: 'overclock_v1',
    name: 'CPU Overclock v1.0',
    description: 'CP獲得倍率を +0.1 加算する。初期衝動。',
    price: 1000,
    type: ShopItemType.multiplier,
    effectValue: 0.1,
  ),
  const ShopItem(
    id: 'gpu_boost',
    name: 'GPU Turbo Boost',
    description: 'CP獲得倍率を +0.2 加算する。描画負荷増大。',
    price: 5000,
    type: ShopItemType.multiplier,
    effectValue: 0.2,
  ),
  const ShopItem(
    id: 'crypto_miner',
    name: 'Illegal Miner',
    description: 'CP獲得倍率を +0.5 加算する。背徳の味。',
    price: 20000,
    type: ShopItemType.multiplier,
    effectValue: 0.5,
  ),
  const ShopItem(
    id: 'quantum_core',
    name: 'Quantum Core',
    description: 'CP獲得倍率を +1.0 加算する。物理法則の無視。',
    price: 100000,
    type: ShopItemType.multiplier,
    effectValue: 1.0,
  ),

  // --- スキン (Visual Hacks) ---
  const ShopItem(
    id: 'skin_matrix',
    name: 'VISUAL HACK: MATRIX',
    description: '攻撃エフェクトを「デジタルコード」に書き換える。',
    price: 3000,
    type: ShopItemType.skin,
    skinAssetId: 'matrix',
  ),
  const ShopItem(
    id: 'skin_gem',
    name: 'VISUAL HACK: GREED',
    description: '攻撃エフェクトを「宝石」に書き換える。',
    price: 10000,
    type: ShopItemType.skin,
    skinAssetId: 'gem',
  ),
];
