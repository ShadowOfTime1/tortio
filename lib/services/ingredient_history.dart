import '../models/recipe.dart';

/// Возвращает список имён ингредиентов из всех рецептов, отсортированный
/// по частоте использования (самые популярные первыми).
List<String> ingredientHistory(List<Recipe> recipes) {
  final counts = <String, int>{};
  final display = <String, String>{}; // canonical (first casing)
  for (final r in recipes) {
    for (final s in r.sections) {
      for (final ing in s.ingredients) {
        final name = ing.name.trim();
        if (name.isEmpty) continue;
        final key = name.toLowerCase();
        display.putIfAbsent(key, () => name);
        counts.update(key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
  }
  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.map((e) => display[e.key]!).toList();
}
