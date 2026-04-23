import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Синглтон-стор для ThemeMode: читает и пишет предпочтение пользователя
/// (system / light / dark) в SharedPreferences, уведомляет слушателей.
class ThemeService extends ChangeNotifier {
  static const _key = 'theme_mode';
  static final ThemeService instance = ThemeService._();

  ThemeService._();

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _mode = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode m) async {
    if (_mode == m) return;
    _mode = m;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _encode(m));
  }

  /// Циклический переключатель: system → light → dark → system.
  Future<void> cycle() async {
    final next = switch (_mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setMode(next);
  }

  IconData get icon => switch (_mode) {
    ThemeMode.system => Icons.brightness_auto,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  String get label => switch (_mode) {
    ThemeMode.system => 'Авто',
    ThemeMode.light => 'Светлая',
    ThemeMode.dark => 'Тёмная',
  };

  static String _encode(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
