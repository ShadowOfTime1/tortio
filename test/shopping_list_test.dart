import 'package:flutter_test/flutter_test.dart';
import 'package:tortio/models/recipe.dart';
import 'package:tortio/services/shopping_list.dart';

void main() {
  RecipeSection section(
    String name,
    ScaleType scaleType,
    Map<String, double> ingredients, {
    String unit = 'г',
  }) {
    return RecipeSection(
      type: SectionType(name: name, icon: '🍰', scaleType: scaleType),
      ingredients: ingredients.entries
          .map((e) => Ingredient(
                name: e.key,
                amount: e.value,
                scaleType: scaleType,
                unit: unit,
              ))
          .toList(),
    );
  }

  double? amountOf(List<AggregatedIngredient> list, String name,
      {String unit = 'г'}) {
    for (final i in list) {
      if (i.name == name && i.unit == unit) return i.amount;
    }
    return null;
  }

  group('aggregateIngredients', () {
    test('пустой ввод возвращает пустой список', () {
      expect(aggregateIngredients([]), isEmpty);
    });

    test('один ингредиент в одной секции — отдаётся как есть', () {
      final result = aggregateIngredients([
        section('Бисквит', ScaleType.volume, {'Мука': 200}),
      ]);
      expect(result.length, 1);
      expect(amountOf(result, 'Мука'), 200);
    });

    test(
      'одинаковые ингредиенты в разных секциях суммируются',
      () {
        final result = aggregateIngredients([
          section('Бисквит', ScaleType.volume, {'Мука': 200, 'Сахар': 150}),
          section('Крем', ScaleType.volume, {'Сахар': 100, 'Сливки': 300}),
        ]);
        expect(amountOf(result, 'Мука'), 200);
        expect(amountOf(result, 'Сахар'), 250);
        expect(amountOf(result, 'Сливки'), 300);
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
        expect(result.length, 1);
        expect(result.first.name, 'Мука');
        expect(result.first.amount, 175);
      },
    );

    test('пустые имена игнорируются', () {
      final result = aggregateIngredients([
        section('A', ScaleType.volume, {'': 100, 'Мука': 50, '   ': 25}),
      ]);
      expect(result.length, 1);
      expect(amountOf(result, 'Мука'), 50);
    });

    test('пробелы по краям тримятся при сравнении', () {
      final result = aggregateIngredients([
        section('A', ScaleType.volume, {'Мука': 100}),
        section('B', ScaleType.volume, {'  Мука  ': 50}),
      ]);
      expect(result.length, 1);
      expect(amountOf(result, 'Мука'), 150);
    });

    test('одно имя с разными единицами — две отдельные записи', () {
      final result = aggregateIngredients([
        section('A', ScaleType.volume, {'Яйца': 60}, unit: 'г'),
        section('B', ScaleType.volume, {'Яйца': 2}, unit: 'шт'),
      ]);
      expect(result.length, 2);
      expect(amountOf(result, 'Яйца', unit: 'г'), 60);
      expect(amountOf(result, 'Яйца', unit: 'шт'), 2);
    });

    test('двойные пробелы внутри имени схлопываются', () {
      final result = aggregateIngredients([
        section('A', ScaleType.volume, {'Сахар тростниковый': 100}),
        section('B', ScaleType.volume, {'Сахар  тростниковый': 50}),
      ]);
      expect(result.length, 1);
      expect(result.first.amount, 150);
    });

    test('точка/запятая в конце имени игнорируются', () {
      final result = aggregateIngredients([
        section('A', ScaleType.volume, {'Сахар.': 100}),
        section('B', ScaleType.volume, {'Сахар': 50}),
        section('C', ScaleType.volume, {'Сахар,': 25}),
      ]);
      expect(result.length, 1);
      expect(result.first.amount, 175);
    });
  });
}
