import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';
import '../models/category_tag.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _repository = SettingsRepository();
  List<ShortcutItem> _allCandidates = [];
  List<String> _currentIds = [];
  String? _defaultPaymentLabel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final candidates = _repository.getAllCandidates();
    final ids = await _repository.loadShortcutIds();
    final defPayment = await _repository.loadDefaultPaymentMethod();
    setState(() {
      _allCandidates = candidates;
      _currentIds = ids;
      _defaultPaymentLabel = defPayment;
    });
  }

  Future<void> _toggle(String id, bool isEnabled) async {
    setState(() {
      if (isEnabled) {
        // 追加: 末尾に追加
        if (!_currentIds.contains(id)) {
          _currentIds.add(id);
        }
      } else {
        // 削除
        _currentIds.remove(id);
      }
    });
    await _repository.saveShortcutIds(_currentIds);
  }

  Future<void> _changeDefaultPayment(String? newValue) async {
    if (newValue == null) {
      await _repository.clearDefaultPaymentMethod();
    } else {
      await _repository.saveDefaultPaymentMethod(newValue);
    }
    setState(() {
      _defaultPaymentLabel = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 費目グループと支払いグループに分ける
    final expenseItems = _allCandidates
        .where((i) => i.key == 'expense')
        .toList();
    final paymentItems = _allCandidates
        .where((i) => i.key == 'payment')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          _buildHeader('入力の初期設定'),
          ListTile(
            title: const Text('デフォルトの支払い方法'),
            subtitle: const Text('入力画面を開いた時に最初から選択状態にします'),
            trailing: DropdownButton<String>(
              value: _defaultPaymentLabel,
              hint: const Text('指定なし'),
              underline: Container(), // 下線を消す
              items: [
                const DropdownMenuItem(value: null, child: Text('指定なし')),
                ...paymentTags.map((tag) {
                  return DropdownMenuItem(
                    value: tag.label,
                    child: Text(tag.label, style: TextStyle(color: tag.color)),
                  );
                }),
              ],
              onChanged: _changeDefaultPayment,
            ),
          ),
          const Divider(),
          _buildHeader('ホーム画面のショートカット'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ホーム画面中央に表示するボタンを選択してください。\n3つ程度がレイアウト的に最適です。',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const Divider(),
          _buildSectionLabel('費目'),
          ...expenseItems.map((item) => _buildSwitchTile(item)),
          const Divider(),
          _buildSectionLabel('支払い方法'),
          ...paymentItems.map((item) => _buildSwitchTile(item)),
          const SizedBox(height: 50),
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSwitchTile(ShortcutItem item) {
    final isSelected = _currentIds.contains(item.id);
    return SwitchListTile(
      title: Text(item.label),
      subtitle: item.label == 'デフォルト'
          ? Text(item.key == 'expense' ? '未分類の費目' : '現金などのデフォルト支払い')
          : null,
      secondary: CircleAvatar(
        backgroundColor: item.color.withOpacity(0.1),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      value: isSelected,
      onChanged: (val) => _toggle(item.id, val),
      activeColor: Colors.blue,
    );
  }
}
