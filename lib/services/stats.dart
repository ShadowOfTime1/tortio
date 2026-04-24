import '../models/recipe.dart';

class TortioStats {
  final int recipeCount;
  final int totalIngredientCount; // суммарно по всем секциям всех рецептов
  final double totalWeight; // сумма Recipe.weight (что пользователь ввёл)
  final List<MapEntry<String, int>> topIngredients;
  final List<MapEntry<String, int>> topTags;

  const TortioStats({
    required this.recipeCount,
    required this.totalIngredientCount,
    required this.totalWeight,
    required this.topIngredients,
    required this.topTags,
  });
}

TortioStats computeStats(List<Recipe> recipes) {
  final ingredientCounts = <String, int>{};
  final ingredientDisplay = <String, String>{};
  var totalIngredients = 0;
  for (final r in recipes) {
    for (final s in r.sections) {
      for (final ing in s.ingredients) {
        totalIngredients++;
        final name = ing.name.trim();
        if (name.isEmpty) continue;
        final key = name.toLowerCase();
        ingredientDisplay.putIfAbsent(key, () => name);
        ingredientCounts.update(key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
  }
  final topIngredients =
      ingredientCounts.entries
          .map((e) => MapEntry(ingredientDisplay[e.key]!, e.value))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  final tagCounts = <String, int>{};
  for (final r in recipes) {
    for (final t in r.tags) {
      tagCounts.update(t, (v) => v + 1, ifAbsent: () => 1);
    }
  }
  final topTags = tagCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final totalWeight = recipes.fold<double>(0, (sum, r) => sum + r.weight);

  return TortioStats(
    recipeCount: recipes.length,
    totalIngredientCount: totalIngredients,
    totalWeight: totalWeight,
    topIngredients: topIngredients.take(5).toList(),
    topTags: topTags.take(5).toList(),
  );
}
