import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class StorageService {
  static const String _key = 'recipes';
  static const String _backupKey = 'recipes_backup';
  static const String _importSnapshotKey = 'pre_import_backup';

  static Future<List<Recipe>> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    return _tryLoad(prefs, _key) ?? _tryLoad(prefs, _backupKey) ?? [];
  }

  static List<Recipe>? _tryLoad(SharedPreferences prefs, String key) {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => _recipeFromJson(j)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    // Сохраняем предыдущее значение в backup перед записью нового —
    // если новый JSON окажется битым, на следующем старте loadRecipes
    // поднимет рецепты из бэкапа, а не вернёт пустой список.
    final previous = prefs.getString(_key);
    if (previous != null) {
      await prefs.setString(_backupKey, previous);
    }
    final jsonList = recipes.map((r) => _recipeToJson(r)).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  /// Снимок текущей коллекции, чтобы можно было откатить недавний импорт.
  /// Если рецептов не было — сохраняет пустой массив, чтобы restore мог
  /// корректно обнулить.
  static Future<void> saveImportSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_importSnapshotKey, prefs.getString(_key) ?? '[]');
  }

  static Future<bool> hasImportSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_importSnapshotKey);
  }

  static Future<void> restoreImportSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final snap = prefs.getString(_importSnapshotKey);
    if (snap == null) return;
    await prefs.setString(_key, snap);
    await prefs.remove(_importSnapshotKey);
  }

  static Map<String, dynamic> _recipeToJson(Recipe r) {
    return {
      'id': r.id,
      'title': r.title,
      'diameter': r.diameter,
      'height': r.height,
      'weight': r.weight,
      'notes': r.notes,
      'tags': r.tags,
      'imagePath': r.imagePath,
      if (r.rating > 0) 'rating': r.rating,
      if (r.additionalTiers.isNotEmpty)
        'additionalTiers': r.additionalTiers.map(_tierToJson).toList(),
      'sections': r.sections.map(_sectionToJson).toList(),
    };
  }

  static Recipe _recipeFromJson(Map<String, dynamic> j) {
    return Recipe(
      id: j['id'],
      title: j['title'],
      diameter: (j['diameter'] as num).toDouble(),
      height: (j['height'] as num).toDouble(),
      weight: (j['weight'] as num?)?.toDouble() ?? 0,
      notes: (j['notes'] as String?) ?? '',
      tags: (j['tags'] as List?)?.map((t) => t as String).toList() ?? const [],
      imagePath: (j['imagePath'] as String?) ?? '',
      rating: (j['rating'] as int?) ?? 0,
      sections: (j['sections'] as List).map(_sectionFromJson).toList(),
      additionalTiers:
          (j['additionalTiers'] as List?)
              ?.map((t) => _tierFromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static Map<String, dynamic> _tierToJson(TierData t) {
    return {
      'diameter': t.diameter,
      'height': t.height,
      'label': t.label,
      'sections': t.sections.map(_sectionToJson).toList(),
    };
  }

  static TierData _tierFromJson(Map<String, dynamic> j) {
    return TierData(
      diameter: (j['diameter'] as num).toDouble(),
      height: (j['height'] as num).toDouble(),
      label: (j['label'] as String?) ?? '',
      sections: (j['sections'] as List).map(_sectionFromJson).toList(),
    );
  }

  static Map<String, dynamic> _sectionToJson(RecipeSection s) {
    return {
      'typeName': s.type.name,
      'typeIcon': s.type.icon,
      'scaleType': s.type.scaleType.index,
      'notes': s.notes,
      'ingredients': s.ingredients
          .map(
            (i) => {
              'name': i.name,
              'amount': i.amount,
              'scaleType': i.scaleType.index,
            },
          )
          .toList(),
    };
  }

  static RecipeSection _sectionFromJson(dynamic raw) {
    final s = raw as Map<String, dynamic>;
    final scaleType = ScaleType.values[s['scaleType'] as int];
    return RecipeSection(
      type: SectionType(
        name: s['typeName'],
        icon: s['typeIcon'],
        scaleType: scaleType,
      ),
      notes: (s['notes'] as String?) ?? '',
      ingredients: (s['ingredients'] as List).map((i) {
        return Ingredient(
          name: i['name'],
          amount: (i['amount'] as num).toDouble(),
          scaleType: ScaleType.values[i['scaleType'] as int],
        );
      }).toList(),
    );
  }
}
