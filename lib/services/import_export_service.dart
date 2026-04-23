import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
    final dateStr = DateTime.now()
        .toIso8601String()
        .substring(0, 10); // YYYY-MM-DD
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
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return 0;

    final path = result.files.single.path;
    if (path == null) return 0;

    final content = await File(path).readAsString();
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
          sections: r.sections,
        ),
      );
    }

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
      'sections': r.sections
          .map(
            (s) => {
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
            },
          )
          .toList(),
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
      sections: (j['sections'] as List).map((s) {
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
      }).toList(),
    );
  }
}
