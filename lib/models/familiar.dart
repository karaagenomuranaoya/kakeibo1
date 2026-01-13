import 'package:flutter/material.dart';

enum SkillType {
  none,
  lowCostBonus,
  nightBonus,
  randomCritical,
  passiveBoost,
  highRoller,
}

class Familiar {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final int rarity;
  final SkillType skillType;
  final String skillName;
  final String skillDescription;

  const Familiar({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    required this.rarity,
    this.skillType = SkillType.none,
    this.skillName = '',
    this.skillDescription = '',
  });
}

// マスターデータ
final List<Familiar> familiarMasterList = [
  // Common
  Familiar(
    id: 'bit_slime',
    name: 'Bit Slime',
    description: 'データのカスから生まれたスライム',
    emoji: '💧',
    color: Colors.cyanAccent,
    rarity: 1,
    skillType: SkillType.lowCostBonus,
    skillName: 'Micro Saver',
    // ★修正: CP -> BD
    skillDescription: '¥1,000以下の入力時、BD獲得量 +50%',
  ),
  Familiar(
    id: 'bug_rat',
    name: 'Bug Rat',
    description: '配線をかじるのが好きなネズミ',
    emoji: '🐀',
    color: Colors.grey,
    rarity: 1,
    skillType: SkillType.passiveBoost,
    skillName: 'Scavenger',
    skillDescription: '常時、BD獲得量 +10%',
  ),

  // Rare
  Familiar(
    id: 'neon_bat',
    name: 'Neon Bat',
    description: '超音波でWi-Fiを探知する',
    emoji: '🦇',
    color: Colors.purpleAccent,
    rarity: 2,
    skillType: SkillType.nightBonus,
    skillName: 'Night Walker',
    skillDescription: '18:00〜06:00の入力時、BD獲得量 +50%',
  ),
  Familiar(
    id: 'code_spider',
    name: 'Code Spider',
    description: 'バグを捕食する益虫',
    emoji: '🕷️',
    color: Colors.greenAccent,
    rarity: 2,
    skillType: SkillType.passiveBoost,
    skillName: 'Web Network',
    skillDescription: '常時、BD獲得量 +20%',
  ),

  // Epic
  Familiar(
    id: 'cyber_wolf',
    name: 'Cyber Wolf',
    description: '強固なファイアウォールを突破する牙',
    emoji: '🐺',
    color: Colors.blueAccent,
    rarity: 3,
    skillType: SkillType.randomCritical,
    skillName: 'Critical Fang',
    skillDescription: '20%の確率で、BD獲得量 3倍',
  ),
  Familiar(
    id: 'glitch_ghost',
    name: 'Glitch Ghost',
    description: '存在したりしなかったりする幽霊',
    emoji: '👻',
    color: Colors.white70,
    rarity: 3,
    skillType: SkillType.randomCritical,
    skillName: 'Poltergeist',
    skillDescription: '50%の確率でBD 2倍、失敗時は等倍',
  ),

  // Legendary
  Familiar(
    id: 'crypto_dragon',
    name: 'Crypto Dragon',
    description: 'ブロックチェーンの守護者',
    emoji: '🐉',
    color: Colors.orangeAccent,
    rarity: 4,
    skillType: SkillType.randomCritical,
    skillName: 'To The Moon',
    skillDescription: '5%の確率で、BD獲得量 10倍',
  ),
  Familiar(
    id: 'quantum_cat',
    name: 'Quantum Cat',
    description: '観測するまで生死が確定しない猫',
    emoji: '🐱',
    color: Colors.pinkAccent,
    rarity: 4,
    skillType: SkillType.highRoller,
    skillName: 'Schrodinger',
    skillDescription: '¥5,000以上の入力時、BD獲得量 2.5倍',
  ),

  // God
  Familiar(
    id: 'singularity_eye',
    name: 'Singularity',
    description: '全ての収支を見通す神の目',
    emoji: '👁️',
    color: Colors.redAccent,
    rarity: 5,
    skillType: SkillType.passiveBoost,
    skillName: 'Event Horizon',
    skillDescription: '常時、BD獲得量 3倍',
  ),
];
