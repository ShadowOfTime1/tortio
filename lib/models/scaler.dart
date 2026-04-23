import 'recipe.dart';
import 'dart:math';

class RecipeScaler {
  List<RecipeSection> scaleBySize({
    required List<RecipeSection> sections,
    required double originalDiameter,
    required double originalHeight,
    required double newDiameter,
    double? newHeight,
  }) {
    final h = newHeight ?? originalHeight;
    final areaRatio = pow(newDiameter / originalDiameter, 2).toDouble();
    final volumeRatio = areaRatio * (h / originalHeight);

    return sections.map((section) {
      final ratio = switch (section.type.scaleType) {
        ScaleType.volume => volumeRatio,
        ScaleType.area => areaRatio,
        ScaleType.fixed => 1.0,
      };
      return RecipeSection(
        type: section.type,
        ingredients: section.ingredients.map((ing) {
          return ing.copyWith(amount: _round(ing.amount * ratio));
        }).toList(),
      );
    }).toList();
  }

  List<RecipeSection> scaleByWeight({
    required List<RecipeSection> sections,
    required double originalWeight,
    required double newWeight,
  }) {
    // Fixed-секции не меняются с весом, поэтому исключаем их из обоих весов
    // перед расчётом ratio — иначе итоговый вес рецепта не сойдётся с newWeight.
    final fixedWeight = sections
        .where((s) => s.type.scaleType == ScaleType.fixed)
        .expand((s) => s.ingredients)
        .fold<double>(0, (sum, ing) => sum + ing.amount);

    final scalableOriginal = originalWeight - fixedWeight;
    final scalableNew = newWeight - fixedWeight;

    if (scalableOriginal <= 0 || scalableNew <= 0) return sections;

    final ratio = scalableNew / scalableOriginal;

    return sections.map((section) {
      if (section.type.scaleType == ScaleType.fixed) return section;
      return RecipeSection(
        type: section.type,
        ingredients: section.ingredients.map((ing) {
          return ing.copyWith(amount: _round(ing.amount * ratio));
        }).toList(),
      );
    }).toList();
  }

  double _round(double v) {
    if (v >= 100) return v.roundToDouble();
    if (v >= 10) return (v * 10).round() / 10;
    return (v * 100).round() / 100;
  }
}
