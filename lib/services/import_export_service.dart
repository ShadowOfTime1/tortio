import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recipe.dart';
import 'storage_service.dart';

class ImportExportService {
  /// Сохраняет все рецепты в JSON-файл во временной папке и открывает
  /// системный share-диалог. Возвращает путь к файлу.
  static Future<String> exportRecipes(List<Recipe> recipes) async {
    final jsonString = _toJson(recipes);

    final dir = await getTemporaryDirectory();
    final dateStr = DateTime.now().toIso8601String().substring(
      0,
      10,
    ); // YYYY-MM-DD
    final filePath = '${dir.path}/tortio-export-$dateStr.json';
    final file = File(filePath);
    await file.writeAsString(jsonString);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        subject: 'Tortio — экспорт рецептов',
      ),
    );
    return filePath;
  }

  /// Открывает file picker, читает JSON, парсит в рецепты и добавляет к
  /// существующим (без замены). Возвращает число добавленных рецептов.
  /// Выбрасывает исключение на битом JSON.
  static Future<int> importRecipes() async {
    const typeGroup = XTypeGroup(label: 'JSON', extensions: ['json']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return 0;

    final content = await file.readAsString();
    final imported = _fromJson(content);

    final existing = await StorageService.loadRecipes();
    // Импортированным id-шкам даём свежие timestamps, чтобы не было коллизий
    // с существующими рецептами.
    final now = DateTime.now().millisecondsSinceEpoch;
    final renumbered = <Recipe>[];
    for (var i = 0; i < imported.length; i++) {
      final r = imported[i];
      renumbered.add(
        Recipe(
          id: '${now + i}',
          title: r.title,
          diameter: r.diameter,
          height: r.height,
          weight: r.weight,
          notes: r.notes,
          tags: r.tags,
          // Сбрасываем imagePath — путь от другого устройства к нашему файлу
          // не приведёт. Картинки в JSON-импорте не передаются.
          imagePath: '',
          rating: r.rating,
          // Личная статистика готовки сбрасывается при импорте — это «чужие»
          // рецепты для текущего пользователя. Если хочется сохранить, делайте
          // backup-restore вместо импорта.
          cookCount: 0,
          lastCookedAt: 0,
          sections: r.sections,
          additionalTiers: r.additionalTiers,
        ),
      );
    }

    // Снимаем snapshot до изменений — пользователь сможет откатить через
    // "Отменить последний импорт" в меню.
    await StorageService.saveImportSnapshot();
    await StorageService.saveRecipes([...existing, ...renumbered]);
    return renumbered.length;
  }

  static String _toJson(List<Recipe> recipes) {
    final list = recipes.map((r) => _recipeToMap(r)).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  static List<Recipe> _fromJson(String raw) {
    final list = json.decode(raw) as List;
    return list.map((j) => _recipeFromMap(j as Map<String, dynamic>)).toList();
  }

  static Map<String, dynamic> _recipeToMap(Recipe r) {
    return {
      'id': r.id,
      'title': r.title,
      'diameter': r.diameter,
      'height': r.height,
      'weight': r.weight,
      'notes': r.notes,
      'tags': r.tags,
      'imagePath': r.imagePath,
      if (r.rating > 0) 'rating': r.rating,
      if (r.cookCount > 0) 'cookCount': r.cookCount,
      if (r.lastCookedAt > 0) 'lastCookedAt': r.lastCookedAt,
      if (r.additionalTiers.isNotEmpty)
        'additionalTiers': r.additionalTiers.map(_tierToMap).toList(),
      'sections': r.sections.map(_sectionToMap).toList(),
    };
  }

  static Recipe _recipeFromMap(Map<String, dynamic> j) {
    return Recipe(
      id: j['id'] as String,
      title: j['title'] as String,
      diameter: (j['diameter'] as num).toDouble(),
      height: (j['height'] as num).toDouble(),
      weight: (j['weight'] as num?)?.toDouble() ?? 0,
      notes: (j['notes'] as String?) ?? '',
      tags: (j['tags'] as List?)?.map((t) => t as String).toList() ?? const [],
      imagePath: (j['imagePath'] as String?) ?? '',
      rating: (j['rating'] as int?) ?? 0,
      cookCount: (j['cookCount'] as int?) ?? 0,
      lastCookedAt: (j['lastCookedAt'] as int?) ?? 0,
      sections: (j['sections'] as List).map(_sectionFromMap).toList(),
      additionalTiers:
          (j['additionalTiers'] as List?)
              ?.map((t) => _tierFromMap(t as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static Map<String, dynamic> _tierToMap(TierData t) => {
    'diameter': t.diameter,
    'height': t.height,
    'label': t.label,
    'sections': t.sections.map(_sectionToMap).toList(),
  };

  static TierData _tierFromMap(Map<String, dynamic> j) => TierData(
    diameter: (j['diameter'] as num).toDouble(),
    height: (j['height'] as num).toDouble(),
    label: (j['label'] as String?) ?? '',
    sections: (j['sections'] as List).map(_sectionFromMap).toList(),
  );

  static Map<String, dynamic> _sectionToMap(RecipeSection s) => {
    'typeName': s.type.name,
    'typeIcon': s.type.icon,
    'scaleType': s.type.scaleType.index,
    'notes': s.notes,
    'ingredients': s.ingredients
        .map(
          (i) => {
            'name': i.name,
            'amount': i.amount,
            'scaleType': i.scaleType.index,
          },
        )
        .toList(),
  };

  static RecipeSection _sectionFromMap(dynamic raw) {
    final s = raw as Map<String, dynamic>;
    final scaleType = ScaleType.values[s['scaleType'] as int];
    return RecipeSection(
      type: SectionType(
        name: s['typeName'] as String,
        icon: s['typeIcon'] as String,
        scaleType: scaleType,
      ),
      notes: (s['notes'] as String?) ?? '',
      ingredients: (s['ingredients'] as List).map((i) {
        return Ingredient(
          name: i['name'] as String,
          amount: (i['amount'] as num).toDouble(),
          scaleType: ScaleType.values[i['scaleType'] as int],
        );
      }).toList(),
    );
  }
}
