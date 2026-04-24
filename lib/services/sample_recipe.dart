import '../models/recipe.dart';

/// Демо-рецепт для пустого списка — даёт новичку увидеть структуру:
/// несколько секций разного scaleType, ингредиенты, заметки.
Recipe buildSampleRecipe() {
  return Recipe(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: 'Шоколадный торт (пример)',
    diameter: 22,
    height: 8,
    weight: 1500,
    notes:
        'Печь бисквит при 180°C 35–40 мин. Дать остыть, разрезать на 2 коржа. '
        'Прослоить кремом, покрыть глазурью.',
    tags: const ['шоколадный', 'пример'],
    rating: 5,
    sections: [
      RecipeSection(
        type: const SectionType(
          name: 'Бисквит',
          icon: '🍰',
          scaleType: ScaleType.volume,
        ),
        notes: 'Просеять муку с какао перед смешиванием',
        ingredients: [
          Ingredient(name: 'Мука', amount: 200, scaleType: ScaleType.volume),
          Ingredient(name: 'Какао', amount: 50, scaleType: ScaleType.volume),
          Ingredient(name: 'Сахар', amount: 200, scaleType: ScaleType.volume),
          Ingredient(name: 'Яйца', amount: 200, scaleType: ScaleType.volume),
          Ingredient(
            name: 'Сливочное масло',
            amount: 100,
            scaleType: ScaleType.volume,
          ),
        ],
      ),
      RecipeSection(
        type: const SectionType(
          name: 'Крем',
          icon: '🍦',
          scaleType: ScaleType.volume,
        ),
        ingredients: [
          Ingredient(
            name: 'Сливки 33%',
            amount: 400,
            scaleType: ScaleType.volume,
          ),
          Ingredient(
            name: 'Сахарная пудра',
            amount: 80,
            scaleType: ScaleType.volume,
          ),
        ],
      ),
      RecipeSection(
        type: const SectionType(
          name: 'Глазурь',
          icon: '✨',
          scaleType: ScaleType.area,
        ),
        ingredients: [
          Ingredient(
            name: 'Тёмный шоколад',
            amount: 200,
            scaleType: ScaleType.area,
          ),
          Ingredient(
            name: 'Сливки 33%',
            amount: 100,
            scaleType: ScaleType.area,
          ),
        ],
      ),
    ],
  );
}
