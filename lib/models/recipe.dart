enum ScaleType { volume, area, fixed }

class SectionType {
  final String name;
  final String icon;
  final ScaleType scaleType;

  const SectionType({
    required this.name,
    required this.icon,
    required this.scaleType,
  });

  static const List<SectionType> presets = [
    SectionType(name: 'Бисквит', icon: '🍰', scaleType: ScaleType.volume),
    SectionType(name: 'Крем', icon: '🍦', scaleType: ScaleType.volume),
    SectionType(name: 'Начинка', icon: '🍓', scaleType: ScaleType.volume),
    SectionType(name: 'Покрытие', icon: '🎨', scaleType: ScaleType.area),
    SectionType(name: 'Ганаш', icon: '🍫', scaleType: ScaleType.area),
    SectionType(name: 'Пропитка', icon: '💧', scaleType: ScaleType.area),
    SectionType(name: 'Мусс', icon: '☁️', scaleType: ScaleType.volume),
    SectionType(name: 'Безе', icon: '🤍', scaleType: ScaleType.volume),
    SectionType(name: 'Глазурь', icon: '✨', scaleType: ScaleType.area),
    SectionType(name: 'Декор', icon: '🌸', scaleType: ScaleType.fixed),
  ];

  String get scaleLabel => switch (scaleType) {
    ScaleType.volume => 'объём',
    ScaleType.area => 'площадь',
    ScaleType.fixed => 'фикс',
  };
}

class Ingredient {
  final String name;
  final double amount;
  final ScaleType scaleType;

  Ingredient({
    required this.name,
    required this.amount,
    required this.scaleType,
  });

  Ingredient copyWith({double? amount}) {
    return Ingredient(
      name: name,
      amount: amount ?? this.amount,
      scaleType: scaleType,
    );
  }
}

class RecipeSection {
  final SectionType type;
  final List<Ingredient> ingredients;
  final String notes;

  RecipeSection({
    required this.type,
    required this.ingredients,
    this.notes = '',
  });
}

/// Один ярус торта со своим размером и составом.
/// Многоярусный торт = `Recipe` (root-уровень = ярус 1) + `additionalTiers`
/// (ярусы 2+).
class TierData {
  final double diameter;
  final double height;
  final String label; // опционально — «Низ», «Верх», «Малый ярус»
  final List<RecipeSection> sections;

  TierData({
    required this.diameter,
    required this.height,
    this.label = '',
    required this.sections,
  });
}

class Recipe {
  final String id;
  final String title;
  final double diameter;
  final double height;
  final double weight;
  final String notes;
  final List<String> tags;
  final String imagePath;
  final List<RecipeSection> sections;
  // Дополнительные ярусы. Пустой список = одноярусный торт (backward compat).
  // Ярус 1 хранится в root-полях (diameter/height/sections), ярусы 2+ — здесь.
  final List<TierData> additionalTiers;
  // Личный рейтинг рецепта 0-5. 0 = не оценено (звёзды не показываются).
  final int rating;
  // Сколько раз пользователь нажал «Я приготовил».
  final int cookCount;
  // Когда последний раз нажал — millisecondsSinceEpoch. 0 = никогда.
  final int lastCookedAt;
  // Закреплённый рецепт всегда висит сверху списка, поверх любой сортировки.
  final bool pinned;

  Recipe({
    required this.id,
    required this.title,
    required this.diameter,
    required this.height,
    this.weight = 0,
    this.notes = '',
    this.tags = const [],
    this.imagePath = '',
    required this.sections,
    this.additionalTiers = const [],
    this.rating = 0,
    this.cookCount = 0,
    this.lastCookedAt = 0,
    this.pinned = false,
  });

  /// Возвращает копию с инкрементом cookCount и обновлением lastCookedAt.
  Recipe markCooked() {
    return _copyWith(
      cookCount: cookCount + 1,
      lastCookedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Recipe togglePinned() => _copyWith(pinned: !pinned);

  Recipe _copyWith({int? cookCount, int? lastCookedAt, bool? pinned}) {
    return Recipe(
      id: id,
      title: title,
      diameter: diameter,
      height: height,
      weight: weight,
      notes: notes,
      tags: tags,
      imagePath: imagePath,
      sections: sections,
      additionalTiers: additionalTiers,
      rating: rating,
      cookCount: cookCount ?? this.cookCount,
      lastCookedAt: lastCookedAt ?? this.lastCookedAt,
      pinned: pinned ?? this.pinned,
    );
  }

  /// Все ярусы торта: первый собирается из root-полей, остальные из
  /// `additionalTiers`. Никогда не пустой — всегда хотя бы один ярус.
  List<TierData> get allTiers => [
    TierData(diameter: diameter, height: height, sections: sections, label: ''),
    ...additionalTiers,
  ];

  bool get isMultiTier => additionalTiers.isNotEmpty;

  /// Все ингредиенты со всех ярусов, для shopping list / stats.
  List<Ingredient> get allIngredients =>
      allTiers.expand((t) => t.sections).expand((s) => s.ingredients).toList();
}
