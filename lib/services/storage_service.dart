import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class StorageService {
  static const String _key = 'recipes';

  static Future<List<Recipe>> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => _recipeFromJson(j)).toList();
  }

  static Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
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
