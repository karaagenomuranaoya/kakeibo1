import 'package:flutter/material.dart';
import '../models/category_tag.dart';
import '../repositories/category_repository.dart';
import '../repositories/settings_repository.dart'; // 追加
import '../screens/monthly_report_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback? onSettingsChanged;
  final VoidCallback? onReportClosed;

  const AppDrawer({super.key, this.onSettingsChanged, this.onReportClosed});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final SettingsRepository _settingsRepository = SettingsRepository(); // 追加
  List<CategoryTag> _categories = [];
  String _defaultCategoryName = 'デフォルト'; // 初期値

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _categoryRepository.getCategories();
    final defName = await _settingsRepository.getDefaultCategoryName(); // 名前取得

    if (mounted) {
      setState(() {
        _categories = list;
        _defaultCategoryName = defName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'メニュー',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('月別レポート'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MonthlyHistoryScreen(),
                      ),
                    );
                    widget.onReportClosed?.call();
                  },
                ),
                const Divider(),
                _buildSectionHeader("費目別"),
                // ★修正: デフォルト名を反映
                _buildFilterTile(
                  context,
                  CategoryTag(
                    label: _defaultCategoryName,
                    colorValue: 0xFF607D8B, // BlueGrey
                  ),
                ),
                // 動的カテゴリ
                ..._categories.map((tag) => _buildFilterTile(context, tag)),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('設定（カテゴリ編集）'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              // 設定から戻ったら再読み込み
              await _loadData();
              widget.onSettingsChanged?.call();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildFilterTile(BuildContext context, CategoryTag tag) {
    return ListTile(
      leading: Icon(Icons.label, color: tag.color),
      title: Text(tag.label),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HistoryScreen(filterValue: tag.label, color: tag.color),
          ),
        );
      },
    );
  }
}
