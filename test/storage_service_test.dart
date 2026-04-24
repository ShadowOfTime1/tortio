import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tortio/models/recipe.dart';
import 'package:tortio/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Recipe sampleRecipe({String id = 'r1', String notes = ''}) {
    return Recipe(
      id: id,
      title: 'Шоколадный',
      diameter: 22,
      height: 8,
      weight: 1500,
      notes: notes,
      sections: [
        RecipeSection(
          type: SectionType(
            name: 'Бисквит',
            icon: '🍰',
            scaleType: ScaleType.volume,
          ),
          ingredients: [
            Ingredient(name: 'Мука', amount: 200, scaleType: ScaleType.volume),
          ],
        ),
      ],
    );
  }

  group('StorageService миграция', () {
    test('пустые prefs → пустой список', () async {
      expect(await StorageService.loadRecipes(), isEmpty);
    });

    test('save затем load — round-trip', () async {
      final r = sampleRecipe(notes: 'печь 30 мин');
      await StorageService.saveRecipes([r]);
      final loaded = await StorageService.loadRecipes();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'Шоколадный');
      expect(loaded.first.notes, 'печь 30 мин');
      expect(loaded.first.sections.first.ingredients.first.name, 'Мука');
    });

    test('одноярусный рецепт сохраняется без поля additionalTiers', () async {
      await StorageService.saveRecipes([sampleRecipe()]);
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('recipes')!;
      // Поле включаем только если ярусов > 1, иначе мусорим JSON старым клиентам.
      expect(raw.contains('additionalTiers'), isFalse);
    });

    test('многоярусный рецепт round-trip', () async {
      final r = Recipe(
        id: 'multi',
        title: 'Свадебный',
        diameter: 28,
        height: 12,
        weight: 5000,
        sections: [
          RecipeSection(
            type: SectionType(
              name: 'Бисквит',
              icon: '🍰',
              scaleType: ScaleType.volume,
            ),
            ingredients: [
              Ingredient(name: 'Мука', amount: 800, scaleType: ScaleType.volume),
            ],
          ),
        ],
        additionalTiers: [
          TierData(
            diameter: 22,
            height: 10,
            label: 'Средний',
            sections: [
              RecipeSection(
                type: SectionType(
                  name: 'Крем',
                  icon: '🍦',
                  scaleType: ScaleType.volume,
                ),
                ingredients: [
                  Ingredient(
                    name: 'Сливки',
                    amount: 400,
                    scaleType: ScaleType.volume,
                  ),
                ],
              ),
            ],
          ),
          TierData(
            diameter: 16,
            height: 8,
            label: 'Верх',
            sections: [],
          ),
        ],
      );
      await StorageService.saveRecipes([r]);
      final loaded = await StorageService.loadRecipes();
      expect(loaded.length, 1);
      expect(loaded.first.allTiers.length, 3);
      expect(loaded.first.additionalTiers.length, 2);
      expect(loaded.first.additionalTiers[0].label, 'Средний');
      expect(loaded.first.additionalTiers[0].diameter, 22);
      expect(
        loaded.first.additionalTiers[0].sections.first.ingredients.first.amount,
        400,
      );
      expect(loaded.first.additionalTiers[1].sections, isEmpty);
    });

    test('старый JSON без additionalTiers → загружается одноярусным', () async {
      const oldJson =
          '[{"id":"old","title":"Простой","diameter":20,"height":10,'
          '"weight":1000,"sections":[{"typeName":"Бисквит","typeIcon":"🍰",'
          '"scaleType":0,"ingredients":[{"name":"Мука","amount":150,"scaleType":0}]}]}]';
      SharedPreferences.setMockInitialValues({'recipes': oldJson});
      final loaded = await StorageService.loadRecipes();
      expect(loaded.first.additionalTiers, isEmpty);
      expect(loaded.first.isMultiTier, isFalse);
      expect(loaded.first.allTiers.length, 1);
    });

    test('старый JSON без поля notes → загружается с notes=""', () async {
      // Эмулируем рецепт, сохранённый до v1.10.0 (без notes).
      const oldJson =
          '[{"id":"old","title":"Старый рецепт","diameter":20,"height":10,'
          '"weight":1000,"sections":[{"typeName":"Бисквит","typeIcon":"🍰",'
          '"scaleType":0,"ingredients":[{"name":"Мука","amount":150,"scaleType":0}]}]}]';
      SharedPreferences.setMockInitialValues({'recipes': oldJson});

      final loaded = await StorageService.loadRecipes();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'Старый рецепт');
      expect(loaded.first.notes, '');
    });
  });

  group('StorageService бэкап', () {
    test('битый главный JSON → возвращаем бэкап', () async {
      // Главный JSON битый, но в backup лежит валидная версия.
      const validJson =
          '[{"id":"r1","title":"Из бэкапа","diameter":20,"height":10,'
          '"weight":0,"notes":"","sections":[{"typeName":"Бисквит","typeIcon":"🍰",'
          '"scaleType":0,"ingredients":[{"name":"Мука","amount":100,"scaleType":0}]}]}]';
      SharedPreferences.setMockInitialValues({
        'recipes': '{ это не JSON ',
        'recipes_backup': validJson,
      });

      final loaded = await StorageService.loadRecipes();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'Из бэкапа');
    });

    test('и главный, и бэкап биты → пустой список (не падаем)', () async {
      SharedPreferences.setMockInitialValues({
        'recipes': '{ битый ',
        'recipes_backup': '} тоже битый',
      });
      expect(await StorageService.loadRecipes(), isEmpty);
    });

    test('save копирует предыдущий валидный JSON в backup', () async {
      // Первое сохранение — backup пустой (нечего бэкапить).
      await StorageService.saveRecipes([sampleRecipe(id: 'first')]);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('recipes_backup'), isNull);

      // Второе сохранение — старое значение должно уехать в backup.
      await StorageService.saveRecipes([sampleRecipe(id: 'second')]);
      final backup = prefs.getString('recipes_backup');
      expect(backup, isNotNull);
      expect(backup, contains('"id":"first"'));
    });
  });
}
