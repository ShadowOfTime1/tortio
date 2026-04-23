import 'package:flutter_test/flutter_test.dart';
import 'package:tortio/models/recipe.dart';
import 'package:tortio/services/shopping_list.dart';

void main() {
  RecipeSection section(
    String name,
    ScaleType scaleType,
    Map<String, double> ingredients,
  ) {
    return RecipeSection(
      type: SectionType(name: name, icon: '🍰', scaleType: scaleType),
      ingredients: ingredients.entries
          .map((e) => Ingredient(
                name: e.key,
                amount: e.value,
                scaleType: scaleType,
              ))
          .toList(),
    );
  }

  group('aggregateIngredients', () {
    test('пустой ввод возвращает пустую map', () {
      expect(aggregateIngredients([]), isEmpty);
    });

    test('один ингредиент в одной секции — отдаётся как есть', () {
      final result = aggregateIngredients([
        section('Бисквит', ScaleType.volume, {'Мука': 200}),
      ]);
      expect(result, {'Мука': 200});
    });

    test(
      'одинаковые ингредиенты в разных секциях суммируются',
      () {
        final result = aggregateIngredients([
          section('Бисквит', ScaleType.volume, {'Мука': 200, 'Сахар': 150}),
          section('Крем', ScaleType.volume, {'Сахар': 100, 'Сливки': 300}),
        ]);
        expect(result['Мука'], 200);
        expect(result['Сахар'], 250); // 150 + 100
        expect(result['Сливки'], 300);
      },
    );

    test(
      'case-insensitive: МУКА и мука суммируются под написанием первого',
      () {
        final result = aggregateIngredients([
          section('A', ScaleType.volume, {'Мука': 100}),
          section('B', ScaleType.volume, {'мука': 50}),
          section('C', ScaleType.volume, {'МУКА': 25}),
        ]);
        expect(result, {'Мука': 175});
      },
    );

    test('пустые имена игнорируются', () {
      final result = aggregateIngredients([
        section('A', ScaleType.volume, {'': 100, 'Мука': 50, '   ': 25}),
      ]);
      expect(result, {'Мука': 50});
    });

    test('пробелы по краям тримятся при сравнении', () {
      final result = aggregateIngredients([
        section('A', ScaleType.volume, {'Мука': 100}),
        section('B', ScaleType.volume, {'  Мука  ': 50}),
      ]);
      expect(result, {'Мука': 150});
    });
  });
}
