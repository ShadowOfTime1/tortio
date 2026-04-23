import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class StorageService {
  static const String _key = 'recipes';
  static const String _backupKey = 'recipes_backup';

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

  static Map<String, dynamic> _recipeToJson(Recipe r) {
    return {
      'id': r.id,
      'title': r.title,
      'diameter': r.diameter,
      'height': r.height,
      'weight': r.weight,
      'notes': r.notes,
      'sections': r.sections
          .map(
            (s) => {
              'typeName': s.type.name,
              'typeIcon': s.type.icon,
              'scaleType': s.type.scaleType.index,
              'ingredients': s.ingredients
                  .map(
                    (i) => {
                      'name': i.name,
                      'amount': i.amount,
                      'scaleType': i.scaleType.index,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
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
      sections: (j['sections'] as List).map((s) {
        final scaleType = ScaleType.values[s['scaleType'] as int];
        return RecipeSection(
          type: SectionType(
            name: s['typeName'],
            icon: s['typeIcon'],
            scaleType: scaleType,
          ),
          ingredients: (s['ingredients'] as List).map((i) {
            return Ingredient(
              name: i['name'],
              amount: (i['amount'] as num).toDouble(),
              scaleType: ScaleType.values[i['scaleType'] as int],
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
