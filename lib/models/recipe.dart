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

class Recipe {
  final String id;
  final String title;
  final double diameter;
  final double height;
  final double weight;
  final String notes;
  final List<RecipeSection> sections;

  Recipe({
    required this.id,
    required this.title,
    required this.diameter,
    required this.height,
    this.weight = 0,
    this.notes = '',
    required this.sections,
  });

  List<Ingredient> get allIngredients =>
      sections.expand((s) => s.ingredients).toList();
}
