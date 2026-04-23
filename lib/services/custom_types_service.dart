import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

/// Стор пользовательских типов секций (добавленных вручную, помимо `SectionType.presets`).
class CustomTypesService {
  static const _key = 'custom_section_types';

  static Future<List<SectionType>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((j) {
        final m = j as Map<String, dynamic>;
        return SectionType(
          name: m['name'] as String,
          icon: m['icon'] as String,
          scaleType: ScaleType.values[m['scaleType'] as int],
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<SectionType> types) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = types
        .map((t) => {
              'name': t.name,
              'icon': t.icon,
              'scaleType': t.scaleType.index,
            })
        .toList();
    await prefs.setString(_key, json.encode(jsonList));
  }
}
