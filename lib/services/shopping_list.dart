import '../models/recipe.dart';

/// Запись агрегированного ингредиента: имя + единица + суммарное количество.
class AggregatedIngredient {
  final String name;
  final String unit; // 'г' или 'шт'
  final double amount;
  const AggregatedIngredient({
    required this.name,
    required this.unit,
    required this.amount,
  });
}

/// Нормализованный ключ имени для дедупликации: trim, lowercase,
/// схлопывает множественные пробелы/табы в один, стрипает завершающие
/// точку/запятую. «Сахар.», «сахар  », «  Сахар » — все маппятся в одно.
String _normalizeNameKey(String name) {
  return name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[.,;]+$'), '')
      .trim();
}

/// Суммирует ингредиенты с одинаковым названием+единицей.
/// Case-insensitive по имени, сохраняет оригинальное написание из первого
/// вхождения. «Яйца, шт» и «Яйца, г» — две отдельные записи.
List<AggregatedIngredient> aggregateIngredients(List<RecipeSection> sections) {
  // key: 'normalized_name|unit', value: (display_name, total_amount, unit)
  final acc = <String, ({String name, String unit, double amount})>{};
  for (final s in sections) {
    for (final ing in s.ingredients) {
      final displayName = ing.name.trim();
      if (displayName.isEmpty) continue;
      final key = '${_normalizeNameKey(ing.name)}|${ing.unit}';
      final existing = acc[key];
      if (existing == null) {
        acc[key] = (name: displayName, unit: ing.unit, amount: ing.amount);
      } else {
        acc[key] = (
          name: existing.name,
          unit: existing.unit,
          amount: existing.amount + ing.amount,
        );
      }
    }
  }
  return acc.values
      .map(
        (v) => AggregatedIngredient(name: v.name, unit: v.unit, amount: v.amount),
      )
      .toList();
}
