import 'package:flutter/material.dart';

class Familiar {
  final String id;
  final String name;
  final String description;
  final String emoji; // 画像の代わりに絵文字を使用（リッチに見せる加工は画面側で行う）
  final Color color;
  final int rarity; // 1~5

  const Familiar({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    required this.rarity,
  });
}

// マスターデータ：サイバーパンク・ファミリア
final List<Familiar> familiarMasterList = [
  // Common (Rarity 1)
  Familiar(
    id: 'bit_slime',
    name: 'Bit Slime',
    description: 'データのカスから生まれたスライム',
    emoji: '💧',
    color: Colors.cyanAccent,
    rarity: 1,
  ),
  Familiar(
    id: 'bug_rat',
    name: 'Bug Rat',
    description: '配線をかじるのが好きなネズミ',
    emoji: '🐀',
    color: Colors.grey,
    rarity: 1,
  ),

  // Rare (Rarity 2)
  Familiar(
    id: 'neon_bat',
    name: 'Neon Bat',
    description: '超音波でWi-Fiを探知する',
    emoji: '🦇',
    color: Colors.purpleAccent,
    rarity: 2,
  ),
  Familiar(
    id: 'code_spider',
    name: 'Code Spider',
    description: 'バグを捕食する益虫',
    emoji: '🕷️',
    color: Colors.greenAccent,
    rarity: 2,
  ),

  // Epic (Rarity 3)
  Familiar(
    id: 'cyber_wolf',
    name: 'Cyber Wolf',
    description: '強固なファイアウォールを突破する牙',
    emoji: '🐺',
    color: Colors.blueAccent,
    rarity: 3,
  ),
  Familiar(
    id: 'glitch_ghost',
    name: 'Glitch Ghost',
    description: '存在したりしなかったりする幽霊',
    emoji: '👻',
    color: Colors.white70,
    rarity: 3,
  ),

  // Legendary (Rarity 4)
  Familiar(
    id: 'crypto_dragon',
    name: 'Crypto Dragon',
    description: 'ブロックチェーンの守護者',
    emoji: '🐉',
    color: Colors.orangeAccent,
    rarity: 4,
  ),
  Familiar(
    id: 'quantum_cat',
    name: 'Quantum Cat',
    description: '観測するまで生死が確定しない猫',
    emoji: '🐱',
    color: Colors.pinkAccent,
    rarity: 4,
  ),

  // God (Rarity 5)
  Familiar(
    id: 'singularity_eye',
    name: 'Singularity',
    description: '全ての収支を見通す神の目',
    emoji: '👁️',
    color: Colors.redAccent,
    rarity: 5,
  ),
];
