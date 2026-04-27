import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Хранит выбор языка пользователя (system / ru / en) и пересобирает UI
/// при смене. system → используется первый совпадающий с supported из
/// системных, при отсутствии — ru.
class LocaleService extends ChangeNotifier {
  static const _key = 'language';
  static final LocaleService instance = LocaleService._();

  LocaleService._();

  static const supportedLocales = [Locale('ru'), Locale('en')];

  String _pref = 'system';
  String get pref => _pref;

  /// `null` → пусть Flutter сам выбирает по системе среди supportedLocales.
  /// Конкретный Locale — пользователь явно выбрал ru или en.
  Locale? get locale => switch (_pref) {
    'ru' => const Locale('ru'),
    'en' => const Locale('en'),
    _ => null,
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _pref = (raw == 'ru' || raw == 'en') ? raw! : 'system';
    notifyListeners();
  }

  Future<void> setPref(String value) async {
    if (_pref == value) return;
    _pref = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }
}
