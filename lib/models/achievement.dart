import 'package:flutter/material.dart';

enum AchievementType {
  totalAmount, // 累計金額
  inputCount, // 入力回数
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int threshold; // 解除に必要な値（金額 or 回数）
  final IconData icon;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.threshold,
    required this.icon,
  });
}

// ★★★ 実績マスターデータ ★★★
final List<Achievement> allAchievements = [
  // --- 入力回数系（継続こそ力なり） ---
  const Achievement(
    id: 'count_1',
    title: 'First Strike',
    description: '記念すべき最初の一撃（入力）',
    type: AchievementType.inputCount,
    threshold: 1,
    icon: Icons.star_border,
  ),
  const Achievement(
    id: 'count_3',
    title: 'Combo Starter',
    description: '3回の入力を達成。リズムに乗ってきた',
    type: AchievementType.inputCount,
    threshold: 3,
    icon: Icons.repeat,
  ),
  const Achievement(
    id: 'count_10',
    title: 'Habitual Striker',
    description: '10回の入力。習慣の芽生え',
    type: AchievementType.inputCount,
    threshold: 10,
    icon: Icons.history_edu,
  ),
  const Achievement(
    id: 'count_50',
    title: 'Machine Gun Finger',
    description: '50回の入力。指先から煙が出ている',
    type: AchievementType.inputCount,
    threshold: 50,
    icon: Icons.touch_app,
  ),
  const Achievement(
    id: 'count_100',
    title: 'Budget Warrior',
    description: '100回の入力。もはや家計簿は戦いだ',
    type: AchievementType.inputCount,
    threshold: 100,
    icon: Icons.military_tech,
  ),

  // --- 金額系（破壊力） ---
  const Achievement(
    id: 'amount_1000',
    title: 'Pocket Change',
    description: '累計1,000円。戦いは始まったばかり',
    type: AchievementType.totalAmount,
    threshold: 1000,
    icon: Icons.monetization_on_outlined,
  ),
  const Achievement(
    id: 'amount_10000',
    title: 'Wallet Breaker',
    description: '累計1万円。財布の紐が緩み始めた',
    type: AchievementType.totalAmount,
    threshold: 10000,
    icon: Icons.money_off,
  ),
  const Achievement(
    id: 'amount_50000',
    title: 'Economy Mover',
    description: '累計5万円。経済を回している自覚',
    type: AchievementType.totalAmount,
    threshold: 50000,
    icon: Icons.trending_up,
  ),
  const Achievement(
    id: 'amount_100000',
    title: 'Big Spender',
    description: '累計10万円。桁が変わる快感',
    type: AchievementType.totalAmount,
    threshold: 100000,
    icon: Icons.diamond,
  ),
  const Achievement(
    id: 'amount_500000',
    title: 'Capitalism Hero',
    description: '累計50万円。君は資本主義の英雄だ',
    type: AchievementType.totalAmount,
    threshold: 500000,
    icon: Icons.rocket_launch,
  ),
];
