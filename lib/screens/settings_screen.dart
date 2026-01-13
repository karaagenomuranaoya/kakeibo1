import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_tag.dart';
import '../repositories/category_repository.dart';
import '../repositories/settings_repository.dart'; // 追加

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final SettingsRepository _settingsRepository = SettingsRepository(); // 追加

  List<CategoryTag> _categories = [];

  // 設定値
  bool _allowEmpty = true;
  String _defaultName = 'Daily Damage';

  final List<Color> _colorPalette = [
    Colors.redAccent,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _categoryRepository.getCategories();
    final allow = await _settingsRepository.getAllowEmptyCategory();
    final defName = await _settingsRepository.getDefaultCategoryName();

    setState(() {
      _categories = list;
      _allowEmpty = allow;
      _defaultName = defName;
    });
  }

  Future<void> _toggleAllowEmpty(bool val) async {
    await _settingsRepository.setAllowEmptyCategory(val);
    setState(() => _allowEmpty = val);
  }

  Future<void> _editDefaultName() async {
    String newName = _defaultName;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF222244),
          title: Text(
            'DEFAULT NAME',
            style: GoogleFonts.vt323(color: Colors.cyanAccent),
          ),
          content: TextField(
            controller: TextEditingController(text: _defaultName),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan),
              ),
            ),
            onChanged: (val) => newName = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty) {
                  await _settingsRepository.setDefaultCategoryName(newName);
                  setState(() => _defaultName = newName);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text(
                'SAVE',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCategory(String name, Color color) async {
    if (name.isEmpty) return;
    await _categoryRepository.addCategory(
      CategoryTag(label: name, colorValue: color.value),
    );
    _load();
  }

  Future<void> _deleteCategory(String label) async {
    await _categoryRepository.deleteCategory(label);
    _load();
  }

  void _showAddDialog() {
    String newName = '';
    Color selectedColor = _colorPalette[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF222244),
              title: Text(
                'NEW CATEGORY',
                style: GoogleFonts.vt323(color: Colors.cyanAccent),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'CATEGORY NAME',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                    ),
                    onChanged: (val) => newName = val,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'COLOR TAG',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorPalette.map((c) {
                      final isSelected = c.value == selectedColor.value;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: c.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _addCategory(newName, selectedColor);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'ADD',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          _buildHeader('未分類入力の挙動'),
          SwitchListTile(
            title: const Text('カテゴリ未選択を許可'),
            subtitle: const Text('許可する場合、下記のデフォルト名で保存されます'),
            value: _allowEmpty,
            onChanged: _toggleAllowEmpty,
            activeColor: Colors.blue,
          ),
          ListTile(
            title: const Text('デフォルトカテゴリ名'),
            subtitle: Text(
              _defaultName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            trailing: const Icon(Icons.edit),
            enabled: _allowEmpty,
            onTap: _editDefaultName,
          ),
          const Divider(),
          _buildHeader('カスタムカテゴリ設定'),
          if (_categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('カテゴリがありません', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ..._categories.map((item) {
            return ListTile(
              leading: CircleAvatar(backgroundColor: item.color, radius: 12),
              title: Text(item.label),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteCategory(item.label),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.withOpacity(0.1),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
