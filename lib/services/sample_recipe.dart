import '../l10n/app_localizations.dart';
import '../models/recipe.dart';

/// Демо-рецепт для пустого списка — даёт новичку увидеть структуру:
/// несколько секций разного scaleType, ингредиенты, заметки.
/// Текстовое содержимое (title, notes, ингредиенты, теги) генерится в
/// текущей локали — после создания это уже user data, которая не пересоздаётся
/// при смене языка.
Recipe buildSampleRecipe(AppLocalizations l) {
  return Recipe(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: l.sample_title,
    diameter: 22,
    height: 8,
    weight: 1500,
    notes: l.sample_notes,
    tags: [l.sample_tag_chocolate, l.sample_tag_sample],
    rating: 5,
    sections: [
      RecipeSection(
        type: const SectionType(
          name: 'Бисквит',
          icon: '🍰',
          scaleType: ScaleType.volume,
        ),
        notes: l.sample_sponge_notes,
        ingredients: [
          Ingredient(
            name: l.sample_ing_flour,
            amount: 200,
            scaleType: ScaleType.volume,
          ),
          Ingredient(
            name: l.sample_ing_cocoa,
            amount: 50,
            scaleType: ScaleType.volume,
          ),
          Ingredient(
            name: l.sample_ing_sugar,
            amount: 200,
            scaleType: ScaleType.volume,
          ),
          Ingredient(
            name: l.sample_ing_eggs,
            amount: 200,
            scaleType: ScaleType.volume,
          ),
          Ingredient(
            name: l.sample_ing_butter,
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
            name: l.sample_ing_cream33,
            amount: 400,
            scaleType: ScaleType.volume,
          ),
          Ingredient(
            name: l.sample_ing_powdered_sugar,
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
            name: l.sample_ing_dark_chocolate,
            amount: 200,
            scaleType: ScaleType.area,
          ),
          Ingredient(
            name: l.sample_ing_cream33,
            amount: 100,
            scaleType: ScaleType.area,
          ),
        ],
      ),
    ],
  );
}
