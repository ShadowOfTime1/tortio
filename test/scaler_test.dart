import 'package:flutter_test/flutter_test.dart';
import 'package:tortio/models/recipe.dart';
import 'package:tortio/models/scaler.dart';

void main() {
  final scaler = RecipeScaler();

  RecipeSection makeSection(
    String name,
    String icon,
    ScaleType scaleType,
    Map<String, double> ingredients,
  ) {
    final type = SectionType(name: name, icon: icon, scaleType: scaleType);
    return RecipeSection(
      type: type,
      ingredients: ingredients.entries
          .map((e) => Ingredient(
                name: e.key,
                amount: e.value,
                scaleType: scaleType,
              ))
          .toList(),
    );
  }

  RecipeSection volume(String name, Map<String, double> ings) =>
      makeSection(name, '🍰', ScaleType.volume, ings);
  RecipeSection area(String name, Map<String, double> ings) =>
      makeSection(name, '🎨', ScaleType.area, ings);
  RecipeSection fixedSec(String name, Map<String, double> ings) =>
      makeSection(name, '🌸', ScaleType.fixed, ings);

  double sumGrams(List<RecipeSection> sections) => sections
      .expand((s) => s.ingredients)
      .fold<double>(0, (acc, i) => acc + i.amount);

  group('RecipeScaler.scaleBySize', () {
    test('удвоение диаметра при той же высоте: volume и area масштабируются ×4',
        () {
      final sections = [
        volume('Бисквит', {'Мука': 100, 'Яйца': 200}),
        area('Покрытие', {'Шоколад': 50}),
      ];

      final result = scaler.scaleBySize(
        sections: sections,
        originalDiameter: 20,
        originalHeight: 10,
        newDiameter: 40,
      );

      expect(result[0].ingredients[0].amount, 400);
      expect(result[0].ingredients[1].amount, 800);
      expect(result[1].ingredients[0].amount, 200);
    });

    test('удвоение диаметра + удвоение высоты: volume ×8, area ×4', () {
      final sections = [
        volume('Крем', {'Сливки': 100}),
        area('Глазурь', {'Шоколад': 50}),
      ];

      final result = scaler.scaleBySize(
        sections: sections,
        originalDiameter: 20,
        originalHeight: 10,
        newDiameter: 40,
        newHeight: 20,
      );

      expect(result[0].ingredients[0].amount, 800);
      expect(result[1].ingredients[0].amount, 200);
    });

    test('fixed-секция не меняется при изменении размера', () {
      final sections = [
        volume('Бисквит', {'Мука': 100}),
        fixedSec('Декор', {'Цветок': 30}),
      ];

      final result = scaler.scaleBySize(
        sections: sections,
        originalDiameter: 20,
        originalHeight: 10,
        newDiameter: 30,
      );

      expect(result[1].ingredients[0].amount, 30);
    });

    test('диаметр не изменился: всё остаётся как было', () {
      final sections = [volume('Бисквит', {'Мука': 200})];

      final result = scaler.scaleBySize(
        sections: sections,
        originalDiameter: 20,
        originalHeight: 10,
        newDiameter: 20,
      );

      expect(result[0].ingredients[0].amount, 200);
    });
  });

  group('RecipeScaler.scaleByWeight', () {
    test('без fixed-секций: пропорциональное масштабирование, итого = newWeight',
        () {
      final sections = [
        volume('Бисквит', {'Мука': 100, 'Сахар': 100}),
        area('Покрытие', {'Глазурь': 100}),
      ];

      final result = scaler.scaleByWeight(
        sections: sections,
        originalWeight: 300,
        newWeight: 600,
      );

      expect(result[0].ingredients[0].amount, 200);
      expect(result[0].ingredients[1].amount, 200);
      expect(result[1].ingredients[0].amount, 200);
      expect(sumGrams(result), 600);
    });

    test(
      'с fixed-секцией: fixed не меняется, итого ≈ newWeight (исправление бага v1.8.0)',
      () {
        final sections = [
          volume('Бисквит', {'Мука': 450}),
          fixedSec('Декор', {'Цветок': 50}),
        ];

        final result = scaler.scaleByWeight(
          sections: sections,
          originalWeight: 500,
          newWeight: 1000,
        );

        // scalable original = 450, scalable new = 950, ratio = 950/450
        // 450 * (950/450) = 950 ровно, _round (>=100) = 950.0
        expect(result[0].ingredients[0].amount, 950);
        expect(result[1].ingredients[0].amount, 50); // fixed не тронут
        expect(sumGrams(result), 1000); // итого совпадает с целевым
      },
    );

    test('целевой вес меньше веса fixed-секций: возврат без изменений', () {
      final sections = [
        volume('Бисквит', {'Мука': 200}),
        fixedSec('Декор', {'Тяжёлая фигура': 300}),
      ];

      final result = scaler.scaleByWeight(
        sections: sections,
        originalWeight: 500,
        newWeight: 200,
      );

      expect(result[0].ingredients[0].amount, 200);
      expect(result[1].ingredients[0].amount, 300);
    });

    test('весь рецепт состоит из fixed: ничего не меняется', () {
      final sections = [
        fixedSec('Декор', {'Цветок': 100}),
      ];

      final result = scaler.scaleByWeight(
        sections: sections,
        originalWeight: 100,
        newWeight: 500,
      );

      expect(result[0].ingredients[0].amount, 100);
    });

    test('тот же вес: значения сохраняются', () {
      final sections = [
        volume('Бисквит', {'Мука': 100}),
        fixedSec('Декор', {'Свечи': 20}),
      ];

      final result = scaler.scaleByWeight(
        sections: sections,
        originalWeight: 120,
        newWeight: 120,
      );

      expect(result[0].ingredients[0].amount, 100);
      expect(result[1].ingredients[0].amount, 20);
    });
  });
}
