import '../l10n/app_localizations.dart';
import '../models/recipe.dart';

/// Заголовки демо-рецептов на всех поддерживаемых локалях. Используется
/// для распознавания нетронутых демо-рецептов при пересоздании их под
/// текущий язык — без хранения признака `isSample` в модели Recipe (чтобы
/// не ломать back-compat существующих сохранений и Drive-бэкапов).
const Set<String> knownSampleTitles = {
  // RU
  'Лёгкий бисквит (пример)',
  'Шоколадный торт (пример)',
  'Свадебный торт (пример)',
  // EN
  'Light sponge (sample)',
  'Chocolate cake (sample)',
  'Wedding cake (sample)',
};

bool isLikelyDemoRecipe(Recipe r) => knownSampleTitles.contains(r.title);

/// Демо-рецепты для пустого списка — 3 штуки разной сложности, чтобы новичок
/// мог сразу пощупать разные сценарии:
/// 1) **Light sponge** — самый простой, один ярус, 2 секции (бисквит + крем).
/// 2) **Chocolate cake** — средняя сложность, добавлена глазурь (area-scaling).
/// 3) **Wedding cake** — двухъярусный, с фиксированным декором.
///
/// Текстовое содержимое (title, notes, ингредиенты, теги) генерится в
/// текущей локали — после создания это уже user data, которая не пересоздаётся
/// при смене языка. Для пересоздания на текущем языке см.
/// `StorageService.regenerateSampleRecipes`.
List<Recipe> buildSampleRecipes(AppLocalizations l) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return [
    _buildSimple(l, now),
    _buildChocolate(l, now + 1),
    _buildWedding(l, now + 2),
  ];
}

Recipe _buildSimple(AppLocalizations l, int id) {
  return Recipe(
    id: id.toString(),
    title: l.sample_simple_title,
    diameter: 18,
    height: 6,
    weight: 600,
    notes: l.sample_simple_notes,
    tags: [l.sample_simple_tag_easy, l.sample_simple_tag_birthday],
    rating: 4,
    sections: [
      RecipeSection(
        type: const SectionType(
          name: 'Бисквит',
          icon: '🍰',
          scaleType: ScaleType.volume,
        ),
        ingredients: [
          Ingredient(name: l.sample_ing_flour, amount: 150, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_sugar, amount: 150, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_eggs, amount: 180, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_butter, amount: 50, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_baking_powder, amount: 5, scaleType: ScaleType.volume),
        ],
      ),
      RecipeSection(
        type: const SectionType(
          name: 'Крем',
          icon: '🍦',
          scaleType: ScaleType.volume,
        ),
        ingredients: [
          Ingredient(name: l.sample_ing_cream33, amount: 250, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_powdered_sugar, amount: 50, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_vanilla, amount: 5, scaleType: ScaleType.volume),
        ],
      ),
    ],
  );
}

Recipe _buildChocolate(AppLocalizations l, int id) {
  return Recipe(
    id: id.toString(),
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
          Ingredient(name: l.sample_ing_flour, amount: 200, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_cocoa, amount: 50, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_sugar, amount: 200, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_eggs, amount: 200, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_butter, amount: 100, scaleType: ScaleType.volume),
        ],
      ),
      RecipeSection(
        type: const SectionType(
          name: 'Крем',
          icon: '🍦',
          scaleType: ScaleType.volume,
        ),
        ingredients: [
          Ingredient(name: l.sample_ing_cream33, amount: 400, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_powdered_sugar, amount: 80, scaleType: ScaleType.volume),
        ],
      ),
      RecipeSection(
        type: const SectionType(
          name: 'Глазурь',
          icon: '✨',
          scaleType: ScaleType.area,
        ),
        ingredients: [
          Ingredient(name: l.sample_ing_dark_chocolate, amount: 200, scaleType: ScaleType.area),
          Ingredient(name: l.sample_ing_cream33, amount: 100, scaleType: ScaleType.area),
        ],
      ),
    ],
  );
}

Recipe _buildWedding(AppLocalizations l, int id) {
  // Tier 1 (root) — нижний ярус (большой). Tier 2 (additionalTiers[0]) — верхний.
  return Recipe(
    id: id.toString(),
    title: l.sample_wedding_title,
    diameter: 26,
    height: 8,
    notes: l.sample_wedding_notes,
    tags: [
      l.sample_wedding_tag_wedding,
      l.sample_wedding_tag_tiered,
      l.sample_wedding_tag_celebration,
    ],
    rating: 5,
    sections: [
      RecipeSection(
        type: const SectionType(
          name: 'Бисквит',
          icon: '🍰',
          scaleType: ScaleType.volume,
        ),
        ingredients: [
          Ingredient(name: l.sample_ing_flour, amount: 300, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_sugar, amount: 300, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_eggs, amount: 360, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_butter, amount: 100, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_baking_powder, amount: 10, scaleType: ScaleType.volume),
        ],
      ),
      RecipeSection(
        type: const SectionType(
          name: 'Крем',
          icon: '🍦',
          scaleType: ScaleType.volume,
        ),
        ingredients: [
          Ingredient(name: l.sample_ing_cream33, amount: 500, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_powdered_sugar, amount: 100, scaleType: ScaleType.volume),
          Ingredient(name: l.sample_ing_vanilla, amount: 8, scaleType: ScaleType.volume),
        ],
      ),
    ],
    additionalTiers: [
      TierData(
        diameter: 16,
        height: 8,
        label: l.sample_wedding_tier_top,
        sections: [
          RecipeSection(
            type: const SectionType(
              name: 'Бисквит',
              icon: '🍰',
              scaleType: ScaleType.volume,
            ),
            ingredients: [
              Ingredient(name: l.sample_ing_flour, amount: 120, scaleType: ScaleType.volume),
              Ingredient(name: l.sample_ing_sugar, amount: 120, scaleType: ScaleType.volume),
              Ingredient(name: l.sample_ing_eggs, amount: 144, scaleType: ScaleType.volume),
              Ingredient(name: l.sample_ing_butter, amount: 40, scaleType: ScaleType.volume),
              Ingredient(name: l.sample_ing_baking_powder, amount: 4, scaleType: ScaleType.volume),
            ],
          ),
          RecipeSection(
            type: const SectionType(
              name: 'Крем',
              icon: '🍦',
              scaleType: ScaleType.volume,
            ),
            ingredients: [
              Ingredient(name: l.sample_ing_cream33, amount: 200, scaleType: ScaleType.volume),
              Ingredient(name: l.sample_ing_powdered_sugar, amount: 40, scaleType: ScaleType.volume),
            ],
          ),
          RecipeSection(
            type: const SectionType(
              name: 'Декор',
              icon: '🌸',
              scaleType: ScaleType.fixed,
            ),
            ingredients: [
              Ingredient(name: l.sample_ing_sugar_figures, amount: 80, scaleType: ScaleType.fixed),
            ],
          ),
        ],
      ),
    ],
  );
}
