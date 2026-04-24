import 'package:shared_preferences/shared_preferences.dart';

/// Маленький фасад над SharedPreferences для пользовательских настроек.
/// Все ключи в одном месте + дефолты.
class AppSettings {
  // === keys ===
  static const _kQuickDiameters = 'quick_diameters';
  static const _kDefaultScaleMode = 'default_scale_mode'; // 'size' | 'weight'
  static const _kAutoUpdateCheck = 'auto_update_check';
  static const _kSortOrder = 'sort_order';
  static const _kThemeMode = 'theme_mode';

  // Все ключи, которые относятся к "настройкам приложения" (не к данным).
  // Используется в reset() для частичной чистки.
  static const _allSettingsKeys = [
    _kQuickDiameters,
    _kDefaultScaleMode,
    _kAutoUpdateCheck,
    _kSortOrder,
    _kThemeMode,
  ];

  // === defaults ===
  static const List<int> defaultQuickDiameters = [16, 18, 20, 22, 24, 26];
  static const String defaultScaleMode = 'size';

  // === quick diameters ===
  static Future<List<int>> loadQuickDiameters() async {
    final prefs = await SharedPreferences.getInstance();
    return parseQuickDiameters(prefs.getString(_kQuickDiameters));
  }

  static Future<void> saveQuickDiameters(List<int> diameters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kQuickDiameters, diameters.join(','));
  }

  /// Парсит строку "16,18,20" в список int. Игнорирует мусор. Возвращает
  /// дефолт если ввод пустой или совсем нечитаемый.
  static List<int> parseQuickDiameters(String? raw) {
    if (raw == null || raw.trim().isEmpty) return defaultQuickDiameters;
    final parsed = raw
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .where((v) => v != null && v > 0 && v <= 60)
        .cast<int>()
        .toList();
    return parsed.isEmpty ? defaultQuickDiameters : parsed;
  }

  // === default scale mode ===
  static Future<String> loadDefaultScaleMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kDefaultScaleMode) ?? defaultScaleMode;
  }

  static Future<void> saveDefaultScaleMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultScaleMode, mode);
  }

  // === reset ===
  /// Чистит только настройки (тема, сортировка, дефолты), сохраняя
  /// рецепты, кастомные типы и snapshot бэкапы.
  static Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in _allSettingsKeys) {
      await prefs.remove(k);
    }
  }
}
