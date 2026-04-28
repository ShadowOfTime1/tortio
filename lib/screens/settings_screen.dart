import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/recipe.dart';
import '../services/app_settings.dart';
import '../services/custom_types_service.dart';
import '../services/drive_backup_service.dart';
import '../l10n/app_localizations.dart';
import '../services/import_export_service.dart';
import '../services/locale_service.dart';
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
    _toast(AppLocalizations.of(context).settings_quick_diameters_saved);
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
      final l = AppLocalizations.of(context);
      if (update == null) {
        _toast(l.settings_check_update_done);
      } else {
        _toast(l.settings_check_update_available(update.version));
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
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.settings_reset_dialog_title),
        content: Text(l.settings_reset_dialog_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8A),
            ),
            child: Text(l.settings_reset_action),
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
    if (!mounted) return;
    _toast(AppLocalizations.of(context).settings_reset_settings_done);
  }

  Future<void> _exportRecipes() async {
    final l = AppLocalizations.of(context);
    final recipes = await StorageService.loadRecipes();
    if (recipes.isEmpty) {
      _toast(l.settings_export_empty);
      return;
    }
    try {
      await ImportExportService.exportRecipes(recipes);
    } catch (e) {
      _toast(l.settings_export_error(e.toString()));
    }
  }

  Future<void> _importRecipes() async {
    final l = AppLocalizations.of(context);
    try {
      final count = await ImportExportService.importRecipes();
      if (count == 0) {
        _toast(l.settings_import_nothing);
      } else {
        _toast(l.settings_import_count(count));
        await _load();
      }
    } catch (e) {
      _toast(l.settings_import_error_with(e.toString()));
    }
  }

  Future<void> _restoreImport() async {
    await StorageService.restoreImportSnapshot();
    await _load();
    if (!mounted) return;
    _toast(AppLocalizations.of(context).settings_import_undone);
  }

  /// Колбэк после успешного восстановления из Google Drive — родительский
  /// MainWrapper перечитает рецепты с диска при следующем resume.
  void _onCloudRestored(int count) {
    _toast(AppLocalizations.of(context).settings_cloud_restore_done(count));
  }

  Future<void> _clearAll() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.settings_delete_all_confirm_title),
        content: Text(l.settings_delete_all_full_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: Text(l.settings_delete_all_action),
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
    if (!mounted) return;
    _toast(AppLocalizations.of(context).settings_delete_all_done);
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
      final l = AppLocalizations.of(context);
      final preview = usedIn.take(5).map((r) => '• ${r.title}').join('\n');
      final more = usedIn.length > 5
          ? '\n${l.custom_type_more(usedIn.length - 5)}'
          : '';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(l.custom_type_used_dialog_title(type.name)),
          content: Text(
            l.custom_type_used_dialog_body(usedIn.length, '$preview$more'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade400,
              ),
              child: Text(l.custom_type_force_delete),
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
            initial == null
                ? AppLocalizations.of(ctx).custom_type_dialog_new
                : AppLocalizations.of(ctx).custom_type_dialog_edit,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).custom_type_field_name,
                  hintText: AppLocalizations.of(
                    ctx,
                  ).custom_type_field_name_hint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).custom_type_field_icon,
                  hintText: '🍡',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(ctx).custom_type_field_scale_label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              RadioGroup<ScaleType>(
                groupValue: selectedScale,
                onChanged: (v) => setDialogState(() => selectedScale = v!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppLocalizations.of(ctx).custom_type_scale_volume,
                      ),
                      value: ScaleType.volume,
                    ),
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppLocalizations.of(ctx).custom_type_scale_area,
                      ),
                      value: ScaleType.area,
                    ),
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppLocalizations.of(ctx).custom_type_scale_fixed,
                      ),
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
              child: Text(AppLocalizations.of(ctx).common_cancel),
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
              child: Text(
                initial == null
                    ? AppLocalizations.of(ctx).custom_type_create
                    : AppLocalizations.of(ctx).common_save,
              ),
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
    final l = AppLocalizations.of(context);
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
                children: [
                  const Icon(
                    Icons.bar_chart_outlined,
                    color: Color(0xFFE85D75),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.stats_title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _statRow(l.stats_recipes, '${stats.recipeCount}'),
              _statRow(l.stats_ingredients, '${stats.totalIngredientCount}'),
              if (stats.totalWeight > 0)
                _statRow(
                  l.stats_total_recipe_weights,
                  formatGrams(stats.totalWeight),
                ),
              const SizedBox(height: 16),
              if (stats.topIngredients.isNotEmpty) ...[
                _sectionLabel(l.stats_top_ingredients_header),
                ...stats.topIngredients.map(
                  (e) => _statRow(e.key, '×${e.value}'),
                ),
                const SizedBox(height: 12),
              ],
              if (stats.topTags.isNotEmpty) ...[
                _sectionLabel(l.stats_top_tags_header),
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
      if (!mounted) return;
      _toast(AppLocalizations.of(context).settings_open_link_failed);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final l = AppLocalizations.of(context);
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final url = Uri.parse(
      isRu
          ? 'https://shadowoftime1.github.io/tortio/privacy-policy-ru/'
          : 'https://shadowoftime1.github.io/tortio/privacy-policy/',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      _toast(l.settings_open_link_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settings_title)),
      body: ListView(
        children: [
          // === Внешний вид ===
          _groupHeader(l.settings_group_appearance),
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

          // === Язык ===
          _groupHeader(AppLocalizations.of(context).settings_language),
          ListenableBuilder(
            listenable: LocaleService.instance,
            builder: (context, _) {
              final l = AppLocalizations.of(context);
              final entries = [
                ('system', l.settings_language_system),
                ('ru', l.settings_language_ru),
                ('en', l.settings_language_en),
              ];
              return Column(
                children: entries.map((e) {
                  return RadioGroup<String>(
                    groupValue: LocaleService.instance.pref,
                    onChanged: (v) {
                      if (v != null) LocaleService.instance.setPref(v);
                    },
                    child: RadioListTile<String>(
                      dense: true,
                      title: Text(e.$2),
                      value: e.$1,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // === Кастомные типы секций ===
          _groupHeader(l.settings_custom_types),
          if (_customTypes.isEmpty)
            ListTile(
              dense: true,
              title: Text(
                l.settings_no_custom_types,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._customTypes.map(
              (t) => ListTile(
                dense: true,
                leading: Text(t.icon, style: const TextStyle(fontSize: 22)),
                title: Text(t.displayName(l)),
                subtitle: Text(
                  l.settings_custom_type_scale_label(t.scaleLabelLocalized(l)),
                ),
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
            title: Text(
              l.settings_custom_types_add,
              style: const TextStyle(color: Color(0xFFE85D75)),
            ),
            onTap: _addCustomType,
          ),

          // === Пересчёт ===
          _groupHeader(l.settings_default_scale_mode),
          ListTile(
            dense: true,
            title: Text(l.settings_quick_diameters),
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
              tooltip: l.common_save,
              onPressed: _saveDiameters,
            ),
          ),
          _groupSubLabel(l.settings_quick_diameters_helper),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _defaultScaleMode,
            onChanged: (v) {
              if (v != null) _setDefaultScaleMode(v);
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  dense: true,
                  title: Text(l.settings_default_mode_size_title),
                  value: 'size',
                ),
                RadioListTile<String>(
                  dense: true,
                  title: Text(l.settings_default_mode_weight_title),
                  subtitle: Text(
                    l.settings_default_mode_weight_subtitle,
                    style: const TextStyle(fontSize: 11),
                  ),
                  value: 'weight',
                ),
              ],
            ),
          ),

          // === Обновления ===
          _groupHeader(l.settings_auto_update),
          SwitchListTile(
            title: Text(l.settings_auto_update),
            subtitle: Text(l.settings_auto_update_subtitle),
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
            title: Text(l.settings_check_update_now),
            onTap: _checkingUpdate ? null : _checkUpdateNow,
          ),

          // === Облачный бэкап ===
          _groupHeader(l.settings_group_cloud),
          _DriveBackupTile(onRestored: _onCloudRestored),

          // === Резервные копии ===
          _groupHeader(l.settings_group_backup),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(l.settings_export),
            onTap: _exportRecipes,
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l.settings_import),
            onTap: _importRecipes,
          ),
          if (_canRestoreImport)
            ListTile(
              leading: const Icon(Icons.undo, color: Colors.orange),
              title: Text(
                l.settings_import_undo_action,
                style: const TextStyle(color: Colors.orange),
              ),
              onTap: _restoreImport,
            ),

          // === Статистика ===
          _groupHeader(l.settings_stats),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: Text(l.settings_show_stats),
            onTap: _showStats,
          ),

          // === Опасная зона ===
          _groupHeader(l.settings_group_danger, color: Colors.red),
          ListTile(
            leading: const Icon(Icons.refresh, color: Color(0xFFFF6B8A)),
            title: Text(
              l.settings_reset_settings,
              style: const TextStyle(color: Color(0xFFE85D75)),
            ),
            subtitle: Text(l.settings_reset_subtitle),
            onTap: _resetSettings,
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.red,
            ),
            title: Text(
              l.settings_delete_all,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: _clearAll,
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // === О приложении ===
          _groupHeader(l.settings_group_about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.settings_version_label),
            trailing: Text('v$_version', style: const TextStyle(fontSize: 14)),
          ),
          ListTile(
            leading: const Icon(Icons.waving_hand_outlined),
            title: Text(l.settings_show_welcome_again),
            subtitle: Text(l.settings_show_welcome_again_subtitle),
            onTap: _showWelcomeAgain,
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l.settings_github_source),
            subtitle: const Text('ShadowOfTime1/tortio'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: _openGitHub,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.settings_privacy_policy),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: _openPrivacyPolicy,
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text(l.settings_license_label),
            trailing: Text(
              l.settings_license_value,
              style: const TextStyle(fontSize: 14),
            ),
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

  String _themeLabel(ThemeMode m) {
    final l = AppLocalizations.of(context);
    return switch (m) {
      ThemeMode.system => l.settings_theme_auto,
      ThemeMode.light => l.settings_theme_light,
      ThemeMode.dark => l.settings_theme_dark,
    };
  }
}

class _DriveBackupTile extends StatefulWidget {
  final void Function(int restoredCount) onRestored;
  const _DriveBackupTile({required this.onRestored});

  @override
  State<_DriveBackupTile> createState() => _DriveBackupTileState();
}

class _DriveBackupTileState extends State<_DriveBackupTile> {
  final _service = DriveBackupService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChange);
  }

  @override
  void dispose() {
    _service.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Future<void> _signIn() async {
    final ok = await _service.signIn();
    if (!ok || !mounted) return;
    final l = AppLocalizations.of(context);
    // После логина — проверяем есть ли существующий бэкап.
    final remoteTime = await _service.remoteBackupTime();
    if (!mounted) return;
    if (remoteTime != null) {
      final restore = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.settings_cloud_restore_prompt_title),
          content: Text(
            l.settings_cloud_restore_prompt_body(_formatDate(remoteTime)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.settings_cloud_restore_keep_local),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.settings_cloud_restore_replace),
            ),
          ],
        ),
      );
      if (restore == true) {
        await _restoreFromCloud();
        return;
      }
    }
    // Иначе — заливаем текущее на сервер.
    final recipes = await StorageService.loadRecipes();
    await _service.uploadNow(_recipesToJson(recipes));
  }

  Future<void> _restoreFromCloud() async {
    final json = await _service.download();
    if (json == null || !mounted) return;
    final count = await _applyCloudJson(json);
    widget.onRestored(count);
  }

  Future<int> _applyCloudJson(String jsonContent) async {
    // Restore: replace (не merge) — облачный бэкап это снимок состояния,
    // не приращение.
    final restored = ImportExportService.parseJsonString(jsonContent);
    await StorageService.saveRecipes(restored);
    return restored.length;
  }

  String _recipesToJson(List<Recipe> recipes) {
    return ImportExportService.recipesToJsonString(recipes);
  }

  String _formatDate(DateTime t) {
    final local = t.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d.$m.${local.year} $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = _service.user;
    if (user == null) {
      return ListTile(
        leading: const Icon(Icons.cloud_off_outlined),
        title: Text(l.settings_cloud_connect),
        subtitle: Text(l.settings_cloud_connect_subtitle),
        trailing: _service.busy
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
        onTap: _service.busy ? null : _signIn,
      );
    }

    final last = _service.lastSync;
    final subtitle = last == null
        ? user.email
        : '${user.email}\n${l.settings_cloud_last_sync(_formatDate(last))}';

    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.cloud_done_outlined,
            color: Color(0xFFE85D75),
          ),
          title: Text(l.settings_cloud_connected),
          subtitle: Text(subtitle),
          isThreeLine: last != null,
        ),
        ListTile(
          leading: const Icon(Icons.sync),
          title: Text(l.settings_cloud_sync_now),
          enabled: !_service.busy,
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final recipes = await StorageService.loadRecipes();
            final ok = await _service.uploadNow(_recipesToJson(recipes));
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  ok ? l.snack_drive_uploaded : l.snack_drive_failed,
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.cloud_download_outlined),
          title: Text(l.settings_cloud_restore),
          enabled: !_service.busy,
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l.settings_cloud_restore_prompt_title),
                content: Text(
                  l.settings_cloud_restore_prompt_body(
                    _service.lastSync != null
                        ? _formatDate(_service.lastSync!)
                        : '?',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(l.common_cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(l.settings_cloud_restore_replace),
                  ),
                ],
              ),
            );
            if (confirm == true) await _restoreFromCloud();
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.grey),
          title: Text(
            l.settings_cloud_sign_out,
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () async => _service.signOut(),
        ),
      ],
    );
  }
}

