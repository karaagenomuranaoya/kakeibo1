import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_tag.dart';

class CategorySelector extends StatelessWidget {
  final List<CategoryTag> tags;
  final int? selectedIndex;
  final int rowCount;
  final Function(int) onSelected;

  const CategorySelector({
    super.key,
    required this.tags,
    required this.selectedIndex,
    required this.rowCount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // 高さを少しコンパクトに
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedIndex == index;

          // 色の決定（選択時はタグの色、非選択時は暗い色）
          final baseColor = tag.color;
          final bgColor = isSelected
              ? baseColor.withOpacity(0.2)
              : Colors.transparent;
          final borderColor = isSelected ? baseColor : Colors.white24;
          final textColor = isSelected ? baseColor : Colors.white54;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(4), // 角張らせてSF感を出す
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: baseColor.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  tag.label,
                  style: GoogleFonts.vt323(
                    // レトロPC風フォントがあればベストだが、なければ標準でOK
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
