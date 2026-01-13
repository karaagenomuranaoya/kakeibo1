import 'package:flutter/material.dart';

class CategoryTag {
  final String label;
  final int colorValue; // Colorをintで保存

  const CategoryTag({required this.label, required this.colorValue});

  Color get color => Color(colorValue);

  // JSON変換
  Map<String, dynamic> toJson() => {'label': label, 'colorValue': colorValue};

  factory CategoryTag.fromJson(Map<String, dynamic> json) {
    return CategoryTag(
      label: json['label'] as String,
      colorValue: json['colorValue'] as int,
    );
  }
}

// 初期データ（リセット時や初回起動時に使用）
final List<CategoryTag> defaultCategories = [
  const CategoryTag(label: '食費', colorValue: 0xFFFF9800), // Colors.orange
  const CategoryTag(label: '日用品', colorValue: 0xFF4CAF50), // Colors.green
  const CategoryTag(label: '雑費', colorValue: 0xFF607D8B), // Colors.blueGrey
  const CategoryTag(label: '交際費', colorValue: 0xFFE91E63), // Colors.pink
  const CategoryTag(label: '趣味', colorValue: 0xFF9C27B0), // Colors.purple
];

// 互換性維持のため、定数expenseTagsは廃止し、今後はRepository経由で取得します。
