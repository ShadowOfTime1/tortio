import '../models/recipe.dart';

/// Суммирует ингредиенты с одинаковым названием (case-insensitive),
/// сохраняя оригинальное написание из первого вхождения.
/// Возвращает map (display name → суммарный вес в граммах). Пустые имена
/// игнорируются.
Map<String, double> aggregateIngredients(List<RecipeSection> sections) {
  final amounts = <String, double>{};
  final canonical = <String, String>{};
  for (final s in sections) {
    for (final ing in s.ingredients) {
      final name = ing.name.trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      final display = canonical.putIfAbsent(key, () => name);
      amounts.update(
        display,
        (v) => v + ing.amount,
        ifAbsent: () => ing.amount,
      );
    }
  }
  return amounts;
}
