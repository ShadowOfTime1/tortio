import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recipe.dart';
import '../services/app_settings.dart';
import '../services/custom_types_service.dart';
import '../services/import_export_service.dart';
import '../services/stats.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../services/update_service.dart';
import '../utils.dart';
import '../widgets/welcome_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '...';
  bool _autoUpdateCheck = true;
  List<SectionType> _customTypes = [];
  bool _canRestoreImport = false;
  String _defaultScaleMode = AppSettings.defaultScaleMode;
  final TextEditingController _diametersController = TextEditingController();
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _diametersController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    final types = await CustomTypesService.load();
    final hasSnapshot = await StorageService.hasImportSnapshot();
    final diameters = await AppSettings.loadQuickDiameters();
    final scaleMode = await AppSettings.loadDefaultScaleMode();
    if (!mounted) return;
    setState(() {
      _version = info.version;
      _autoUpdateCheck = prefs.getBool('auto_update_check') ?? true;
      _customTypes = types;
      _canRestoreImport = hasSnapshot;
      _defaultScaleMode = scaleMode;
      _diametersController.text = diameters.join(', ');
    });
  }

  Future<void> _setAutoUpdate(bool v) async {
    setState(() => _autoUpdateCheck = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_update_check', v);
  }

  Future<void> _saveDiameters() async {
    final list = AppSettings.parseQuickDiameters(_diametersController.text);
    await AppSettings.saveQuickDiameters(list);
    if (!mounted) return;
    setState(() => _diametersController.text = list.join(', '));
    _toast('Quick-диаметры сохранены');
  }

  Future<void> _setDefaultScaleMode(String mode) async {
    setState(() => _defaultScaleMode = mode);
    await AppSettings.saveDefaultScaleMode(mode);
  }

  Future<void> _checkUpdateNow() async {
    if (_checkingUpdate) return;
    setState(() => _checkingUpdate = true);
    // Временно «включаем» auto-check, чтобы UpdateService не отказался.
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('auto_update_check');
    await prefs.setBool('auto_update_check', true);
    try {
      final update = await UpdateService.checkForUpdate();
      if (!mounted) return;
      if (update == null) {
        _toast('Установлена последняя версия');
      } else {
        _toast(
          'Доступна v${update.version}. Открой приложение заново — '
          'появится баннер с обновлением.',
        );
      }
    } finally {
      // Возвращаем как было.
      if (saved == null) {
        await prefs.remove('auto_update_check');
      } else {
        await prefs.setBool('auto_update_check', saved);
      }
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Сбросить настройки?'),
        content: const Text(
          'Тема, сортировка, авто-проверка обновлений, default-режим '
          'пересчёта и quick-диаметры вернутся к дефолтам. Рецепты и '
          'кастомные типы секций НЕ затронутся.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8A),
            ),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await AppSettings.resetSettings();
    // Подтянуть тему обратно к default (system).
    await ThemeService.instance.load();
    if (!mounted) return;
    await _load();
    _toast('Настройки сброшены');
  }

  Future<void> _exportRecipes() async {
    final recipes = await StorageService.loadRecipes();
    if (recipes.isEmpty) {
      _toast('Нечего экспортировать — список пустой');
      return;
    }
    try {
      await ImportExportService.exportRecipes(recipes);
    } catch (e) {
      _toast('Ошибка экспорта: $e');
    }
  }

  Future<void> _importRecipes() async {
    try {
      final count = await ImportExportService.importRecipes();
      if (count == 0) {
        _toast('Ничего не импортировано');
      } else {
        _toast('Импортировано: $count');
        await _load();
      }
    } catch (e) {
      _toast('Ошибка импорта: $e');
    }
  }

  Future<void> _restoreImport() async {
    await StorageService.restoreImportSnapshot();
    await _load();
    _toast('Импорт откачен');
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Удалить все рецепты?'),
        content: const Text(
          'Все рецепты, кастомные типы секций и snapshot'
          ' импорта будут удалены безвозвратно. Резервная копия'
          ' предыдущего сохранения тоже исчезнет. Уверен?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Удалить всё'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recipes');
    await prefs.remove('recipes_backup');
    await prefs.remove('pre_import_backup');
    await prefs.remove('custom_section_types');
    if (!mounted) return;
    await _load();
    _toast('Всё удалено');
  }

  Future<void> _editCustomType(SectionType type) async {
    final edited = await _showCustomTypeDialog(initial: type);
    if (edited != null) {
      final updated = _customTypes
          .map((t) => t.name == type.name ? edited : t)
          .toList();
      await CustomTypesService.save(updated);
      if (mounted) setState(() => _customTypes = updated);
    }
  }

  Future<void> _deleteCustomType(SectionType type) async {
    // Если тип используется в каких-то рецептах — предупредить.
    final all = await StorageService.loadRecipes();
    final usedIn = all
        .where((r) => r.sections.any((s) => s.type.name == type.name))
        .toList();
    if (!mounted) return;

    if (usedIn.isNotEmpty) {
      final preview = usedIn.take(5).map((r) => '• ${r.title}').join('\n');
      final more = usedIn.length > 5 ? '\n... и ещё ${usedIn.length - 5}' : '';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Удалить тип «${type.name}»?'),
          content: Text(
            'Этот тип используется в ${usedIn.length} рецепте(ах):\n\n'
            '$preview$more\n\n'
            'Уже сохранённые секции продолжат работать как есть. '
            'Но добавить новые секции этого типа будет нельзя.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade400,
              ),
              child: const Text('Всё равно удалить'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final updated = _customTypes.where((t) => t.name != type.name).toList();
    await CustomTypesService.save(updated);
    if (mounted) setState(() => _customTypes = updated);
  }

  Future<void> _addCustomType() async {
    final created = await _showCustomTypeDialog();
    if (created != null) {
      final updated = [..._customTypes, created];
      await CustomTypesService.save(updated);
      if (mounted) setState(() => _customTypes = updated);
    }
  }

  Future<SectionType?> _showCustomTypeDialog({SectionType? initial}) {
    final nameController = TextEditingController(text: initial?.name ?? '');
    final iconController = TextEditingController(text: initial?.icon ?? '🧁');
    ScaleType selectedScale = initial?.scaleType ?? ScaleType.volume;

    return showDialog<SectionType>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            initial == null ? 'Новый тип секции' : 'Изменить тип секции',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Например, Маршмеллоу',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Иконка (эмодзи)',
                  hintText: '🍡',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Как масштабировать',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              RadioGroup<ScaleType>(
                groupValue: selectedScale,
                onChanged: (v) => setDialogState(() => selectedScale = v!),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('По объёму (d² × h)'),
                      value: ScaleType.volume,
                    ),
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('По площади (d²)'),
                      value: ScaleType.area,
                    ),
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Фикс (не меняется)'),
                      value: ScaleType.fixed,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final icon = iconController.text.trim();
                if (name.isEmpty || icon.isEmpty) return;
                Navigator.pop(
                  ctx,
                  SectionType(name: name, icon: icon, scaleType: selectedScale),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B8A),
              ),
              child: Text(initial == null ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStats() async {
    final recipes = await StorageService.loadRecipes();
    if (!mounted) return;
    final stats = computeStats(recipes);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.bar_chart_outlined, color: Color(0xFFE85D75)),
                  SizedBox(width: 8),
                  Text(
                    'Статистика',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _statRow('Рецептов', '${stats.recipeCount}'),
              _statRow('Ингредиентов всего', '${stats.totalIngredientCount}'),
              if (stats.totalWeight > 0)
                _statRow(
                  'Сумма весов рецептов',
                  formatGrams(stats.totalWeight),
                ),
              const SizedBox(height: 16),
              if (stats.topIngredients.isNotEmpty) ...[
                _sectionLabel('ТОП ИНГРЕДИЕНТОВ'),
                ...stats.topIngredients.map(
                  (e) => _statRow(e.key, '×${e.value}'),
                ),
                const SizedBox(height: 12),
              ],
              if (stats.topTags.isNotEmpty) ...[
                _sectionLabel('ТОП ТЕГОВ'),
                ...stats.topTags.map((e) => _statRow(e.key, '×${e.value}')),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE85D75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showWelcomeAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('welcome_seen');
    if (!mounted) return;
    await maybeShowWelcome(context);
  }

  Future<void> _openGitHub() async {
    final url = Uri.parse('https://github.com/ShadowOfTime1/tortio');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _toast('Не удалось открыть ссылку');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          // === Внешний вид ===
          _groupHeader('Внешний вид'),
          ListenableBuilder(
            listenable: ThemeService.instance,
            builder: (context, _) {
              return Column(
                children: ThemeMode.values.map((mode) {
                  return RadioGroup<ThemeMode>(
                    groupValue: ThemeService.instance.mode,
                    onChanged: (v) {
                      if (v != null) ThemeService.instance.setMode(v);
                    },
                    child: RadioListTile<ThemeMode>(
                      dense: true,
                      title: Text(_themeLabel(mode)),
                      value: mode,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // === Кастомные типы секций ===
          _groupHeader('Кастомные типы секций'),
          if (_customTypes.isEmpty)
            const ListTile(
              dense: true,
              title: Text(
                'Нет кастомных типов',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._customTypes.map(
              (t) => ListTile(
                dense: true,
                leading: Text(t.icon, style: const TextStyle(fontSize: 22)),
                title: Text(t.name),
                subtitle: Text('масштаб: ${t.scaleType.name}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _editCustomType(t),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteCustomType(t),
                    ),
                  ],
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add, color: Color(0xFFE85D75)),
            title: const Text(
              'Добавить тип',
              style: TextStyle(color: Color(0xFFE85D75)),
            ),
            onTap: _addCustomType,
          ),

          // === Пересчёт ===
          _groupHeader('Пересчёт'),
          ListTile(
            dense: true,
            title: const Text('Quick-диаметры'),
            subtitle: TextField(
              controller: _diametersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '16, 18, 20, 22, 24, 26',
                isDense: true,
              ),
              onSubmitted: (_) => _saveDiameters(),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.check, color: Color(0xFFE85D75)),
              tooltip: 'Сохранить',
              onPressed: _saveDiameters,
            ),
          ),
          _groupSubLabel(
            'Эти числа показываются как кнопки-чипы под слайдером диаметра '
            'на экране пересчёта.',
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _defaultScaleMode,
            onChanged: (v) {
              if (v != null) _setDefaultScaleMode(v);
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  dense: true,
                  title: Text('По умолчанию: По размеру'),
                  value: 'size',
                ),
                RadioListTile<String>(
                  dense: true,
                  title: Text('По умолчанию: По весу'),
                  subtitle: Text(
                    'Только если у рецепта указан вес',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: 'weight',
                ),
              ],
            ),
          ),

          // === Обновления ===
          _groupHeader('Обновления'),
          SwitchListTile(
            title: const Text('Автоматически проверять обновления'),
            subtitle: const Text(
              'При запуске приложение спрашивает GitHub о новой версии',
            ),
            value: _autoUpdateCheck,
            onChanged: _setAutoUpdate,
          ),
          ListTile(
            leading: _checkingUpdate
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            title: const Text('Проверить обновление сейчас'),
            onTap: _checkingUpdate ? null : _checkUpdateNow,
          ),

          // === Резервные копии ===
          _groupHeader('Резервные копии'),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Экспортировать в JSON'),
            onTap: _exportRecipes,
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Импортировать из JSON'),
            onTap: _importRecipes,
          ),
          if (_canRestoreImport)
            ListTile(
              leading: const Icon(Icons.undo, color: Colors.orange),
              title: const Text(
                'Откатить последний импорт',
                style: TextStyle(color: Colors.orange),
              ),
              onTap: _restoreImport,
            ),

          // === Статистика ===
          _groupHeader('Статистика'),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Показать статистику'),
            onTap: _showStats,
          ),

          // === Опасная зона ===
          _groupHeader('Опасная зона', color: Colors.red),
          ListTile(
            leading: const Icon(Icons.refresh, color: Color(0xFFFF6B8A)),
            title: const Text(
              'Сбросить настройки до дефолтов',
              style: TextStyle(color: Color(0xFFE85D75)),
            ),
            subtitle: const Text(
              'Тема, сортировка, авто-обновление, default режим, '
              'quick-диаметры. Рецепты не трогаются.',
            ),
            onTap: _resetSettings,
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.red,
            ),
            title: const Text(
              'Удалить все рецепты и кастомные типы',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _clearAll,
          ),

          // === О приложении ===
          _groupHeader('О приложении'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Версия'),
            trailing: Text('v$_version', style: const TextStyle(fontSize: 14)),
          ),
          ListTile(
            leading: const Icon(Icons.waving_hand_outlined),
            title: const Text('Показать приветствие снова'),
            subtitle: const Text('Краткий тур по приложению'),
            onTap: _showWelcomeAgain,
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Исходники на GitHub'),
            subtitle: const Text('ShadowOfTime1/tortio'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: _openGitHub,
          ),
          const ListTile(
            leading: Icon(Icons.gavel_outlined),
            title: Text('Лицензия'),
            trailing: Text('MIT', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _groupHeader(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color ?? const Color(0xFFE85D75),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _groupSubLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
      ),
    );
  }

  String _themeLabel(ThemeMode m) => switch (m) {
    ThemeMode.system => 'Авто (день — светлая, вечер — тёмная)',
    ThemeMode.light => 'Светлая',
    ThemeMode.dark => 'Тёмная',
  };
}
