import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../services/custom_types_service.dart';
import '../services/image_picker_service.dart';
import '../services/ingredient_history.dart';
import '../services/storage_service.dart';
import '../utils.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? existingRecipe;
  const AddRecipeScreen({super.key, this.existingRecipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _diameterController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagInputController;
  final List<_SectionInput> _sections = [];
  final List<String> _tags = [];
  List<SectionType> _customTypes = [];
  List<String> _ingredientSuggestions = const [];
  String _imagePath = '';
  bool get _isEditing => widget.existingRecipe != null;

  final List<List<Color>> _sectionColors = [
    [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
    [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
    [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
    [const Color(0xFFF6D365), const Color(0xFFFDA085)],
    [const Color(0xFFFA709A), const Color(0xFFFEE140)],
    [const Color(0xFFFBC2EB), const Color(0xFFA6C1EE)],
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecipe;
    _titleController = TextEditingController(text: r?.title ?? '');
    _diameterController = TextEditingController(
      text: r != null ? '${r.diameter}' : '20',
    );
    _heightController = TextEditingController(
      text: r != null ? '${r.height}' : '10',
    );
    _weightController = TextEditingController(
      text: r != null && r.weight > 0 ? '${r.weight}' : '',
    );
    _notesController = TextEditingController(text: r?.notes ?? '');
    _tagInputController = TextEditingController();
    if (r != null) _tags.addAll(r.tags);
    _imagePath = r?.imagePath ?? '';
    _loadCustomTypes();
    _loadIngredientHistory();
    if (r != null) {
      for (final section in r.sections) {
        final sectionInput = _SectionInput(
          type: section.type,
          notes: section.notes,
        );
        for (final ing in section.ingredients) {
          sectionInput.ingredients.add(
            _IngredientInput(name: ing.name, amount: '${ing.amount}'),
          );
        }
        _sections.add(sectionInput);
      }
    }
  }

  Future<void> _loadCustomTypes() async {
    final types = await CustomTypesService.load();
    if (mounted) setState(() => _customTypes = types);
  }

  Future<void> _loadIngredientHistory() async {
    final all = await StorageService.loadRecipes();
    if (mounted) setState(() => _ingredientSuggestions = ingredientHistory(all));
  }

  void _addSection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _SectionPicker(
        customTypes: _customTypes,
        onSelect: (type) {
          Navigator.pop(ctx);
          setState(() => _sections.add(_SectionInput(type: type)));
        },
        onCreateCustom: () async {
          Navigator.pop(ctx);
          final created = await _showCreateCustomTypeDialog();
          if (created != null) {
            final updated = [..._customTypes, created];
            await CustomTypesService.save(updated);
            if (mounted) {
              setState(() {
                _customTypes = updated;
                _sections.add(_SectionInput(type: created));
              });
            }
          }
        },
        onEditCustom: (oldType) async {
          Navigator.pop(ctx);
          final edited = await _showCreateCustomTypeDialog(initial: oldType);
          if (edited != null) {
            final updated = _customTypes
                .map((t) => t.name == oldType.name ? edited : t)
                .toList();
            await CustomTypesService.save(updated);
            if (mounted) setState(() => _customTypes = updated);
          }
        },
        onDeleteCustom: (type) async {
          Navigator.pop(ctx);
          final updated = _customTypes
              .where((t) => t.name != type.name)
              .toList();
          await CustomTypesService.save(updated);
          if (mounted) setState(() => _customTypes = updated);
        },
      ),
    );
  }

  Future<SectionType?> _showCreateCustomTypeDialog({SectionType? initial}) {
    final nameController = TextEditingController(text: initial?.name ?? '');
    final iconController = TextEditingController(text: initial?.icon ?? '🧁');
    ScaleType selectedScale = initial?.scaleType ?? ScaleType.volume;

    return showDialog<SectionType>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            initial == null ? 'Свой тип секции' : 'Изменить тип секции',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Например, Маршмеллоу',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Иконка (эмодзи)',
                  hintText: '🍡',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Как масштабировать',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              RadioGroup<ScaleType>(
                groupValue: selectedScale,
                onChanged: (v) =>
                    setDialogState(() => selectedScale = v!),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('По объёму (d² × h)'),
                      value: ScaleType.volume,
                    ),
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('По площади (d²)'),
                      value: ScaleType.area,
                    ),
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Фикс (не меняется)'),
                      value: ScaleType.fixed,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final icon = iconController.text.trim();
                if (name.isEmpty || icon.isEmpty) return;
                Navigator.pop(
                  ctx,
                  SectionType(
                    name: name,
                    icon: icon,
                    scaleType: selectedScale,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B8A),
              ),
              child: Text(initial == null ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeSection(int index) {
    setState(() => _sections.removeAt(index));
  }

  void _addIngredient(int sectionIndex) {
    setState(() {
      _sections[sectionIndex].ingredients.add(_IngredientInput());
    });
  }

  void _removeIngredient(int sectionIndex, int ingIndex) {
    setState(() {
      _sections[sectionIndex].ingredients.removeAt(ingIndex);
    });
  }

  void _addTag() {
    final raw = _tagInputController.text.trim();
    if (raw.isEmpty) return;
    // Поддержка ввода нескольких тегов через запятую.
    final newTags = raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty && !_tags.contains(t))
        .toList();
    if (newTags.isEmpty) {
      _tagInputController.clear();
      return;
    }
    setState(() {
      _tags.addAll(newTags);
      _tagInputController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _save() {
    final title = _titleController.text.trim();
    final diameter = parseNumber(_diameterController.text) ?? 0;
    final height = parseNumber(_heightController.text) ?? 0;
    final weight = parseNumber(_weightController.text) ?? 0;

    if (title.isEmpty) {
      _showError('Введите название');
      return;
    }
    if (diameter <= 0 || height <= 0) {
      _showError('Введите размеры формы');
      return;
    }
    if (_sections.isEmpty) {
      _showError('Добавьте хотя бы одну секцию');
      return;
    }

    // Дропаем пустые ингредиенты (пустое имя или вес ≤ 0) и пустые секции,
    // чтобы не сохранять мусор. Если после очистки рецепт пустой — ошибка.
    final cleanSections = _sections
        .map((s) {
          final ingredients = s.ingredients
              .where(
                (ing) =>
                    ing.nameController.text.trim().isNotEmpty &&
                    (parseNumber(ing.amountController.text) ?? 0) > 0,
              )
              .map((ing) {
                return Ingredient(
                  name: ing.nameController.text.trim(),
                  amount: parseNumber(ing.amountController.text) ?? 0,
                  scaleType: s.type.scaleType,
                );
              })
              .toList();
          return RecipeSection(
            type: s.type,
            ingredients: ingredients,
            notes: s.notesController.text.trim(),
          );
        })
        .where((s) => s.ingredients.isNotEmpty)
        .toList();

    if (cleanSections.isEmpty) {
      _showError('Заполните хотя бы один ингредиент с весом > 0');
      return;
    }

    final recipe = Recipe(
      id:
          widget.existingRecipe?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      diameter: diameter,
      height: height,
      weight: weight,
      notes: _notesController.text.trim(),
      tags: List.unmodifiable(_tags),
      imagePath: _imagePath,
      sections: cleanSections,
    );
    Navigator.of(context).pop(recipe);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final path = await ImagePickerService.pickAndPersist(source: source);
      if (path != null && mounted) {
        setState(() => _imagePath = path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Не удалось открыть камеру: $e'
                : 'Не удалось выбрать фото: $e',
          ),
        ),
      );
    }
  }

  void _showImageActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Из галереи'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Сделать фото'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_imagePath.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Убрать фото',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _imagePath = '');
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать' : 'Новый рецепт'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B8A),
              ),
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото-обложка (опционально)
            Center(
              child: GestureDetector(
                onTap: _showImageActions,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: const Color(0xFFFF6B8A).withValues(alpha: 0.3),
                      width: 2,
                    ),
                    image: _imagePath.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(File(_imagePath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: Color(0xFFE85D75),
                                size: 28,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Фото',
                                style: TextStyle(
                                  color: Color(0xFFE85D75),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Название',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Например: Шоколадный торт',
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Размеры формы',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _diameterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '20',
                      suffixText: 'см',
                      labelText: 'Диаметр',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '10',
                      suffixText: 'см',
                      labelText: 'Высота',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Вес (необязательно)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '2000',
                suffixText: 'г',
                labelText: 'Вес',
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Заметки / шаги (необязательно)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Например: испечь при 170°C 35 мин. Бисквит — за день до сборки.',
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Теги (необязательно)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagInputController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addTag(),
              decoration: InputDecoration(
                hintText: 'шоколадный, без глютена',
                helperText: 'Введи тег и нажми Enter (или через запятую)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ),
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tags.map((tag) {
                  return InputChip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    deleteIconColor: Colors.grey.shade500,
                    backgroundColor: const Color(0xFFFF6B8A).withValues(
                      alpha: 0.1,
                    ),
                    labelStyle: const TextStyle(fontSize: 13),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 28),

            // Секции
            Row(
              children: [
                const Text(
                  'Состав',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _addSection,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Секция'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B8A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_sections.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B8A).withValues(alpha: 0.08),
                      const Color(0xFFFF8E53).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF6B8A).withValues(alpha: 0.2),
                  ),
                ),
                child: const Column(
                  children: [
                    Text('🧁', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 12),
                    Text(
                      'Добавьте секцию',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Бисквит, крем, начинка...',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

            if (_sections.isNotEmpty)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _sections.length,
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (newIdx > oldIdx) newIdx -= 1;
                    final s = _sections.removeAt(oldIdx);
                    _sections.insert(newIdx, s);
                  });
                },
                itemBuilder: (context, si) {
                  final section = _sections[si];
                  final colors = _sectionColors[si % _sectionColors.length];

                  return Padding(
                    key: ObjectKey(section),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Заголовок
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors[0].withValues(alpha: 0.2),
                              colors[1].withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              section.type.icon,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section.type.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'пересчёт: ${section.type.scaleLabel}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ReorderableDragStartListener(
                              index: si,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Icon(
                                  Icons.drag_indicator,
                                  size: 20,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeSection(si),
                              icon: const Icon(Icons.close, size: 18),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),

                      // Ингредиенты
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                        child: Column(
                          children: [
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: false,
                              itemCount: section.ingredients.length,
                              onReorder: (oldIdx, newIdx) {
                                setState(() {
                                  if (newIdx > oldIdx) newIdx -= 1;
                                  final i = section.ingredients
                                      .removeAt(oldIdx);
                                  section.ingredients.insert(newIdx, i);
                                });
                              },
                              itemBuilder: (context, ii) {
                                final ing = section.ingredients[ii];
                                return Padding(
                                  key: ObjectKey(ing),
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      ReorderableDragStartListener(
                                        index: ii,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          child: Icon(
                                            Icons.drag_indicator,
                                            size: 18,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Autocomplete<String>(
                                          initialValue: TextEditingValue(
                                            text: ing.nameController.text,
                                          ),
                                          optionsBuilder: (tev) {
                                            if (tev.text.isEmpty) {
                                              return const Iterable<String>.empty();
                                            }
                                            final q = tev.text.toLowerCase();
                                            return _ingredientSuggestions
                                                .where(
                                                  (n) =>
                                                      n
                                                          .toLowerCase()
                                                          .contains(q) &&
                                                      n.toLowerCase() != q,
                                                )
                                                .take(5);
                                          },
                                          fieldViewBuilder:
                                              (ctx, ctrl, fn, submit) {
                                                ing.nameController = ctrl;
                                                return TextField(
                                                  controller: ctrl,
                                                  focusNode: fn,
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText: 'Ингредиент',
                                                        isDense: true,
                                                      ),
                                                );
                                              },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: ing.amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            hintText: '0',
                                            suffixText: 'г',
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeIngredient(si, ii),
                                        icon: const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                        color: Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            TextButton.icon(
                              onPressed: () => _addIngredient(si),
                              icon: Icon(Icons.add, size: 16, color: colors[0]),
                              label: Text(
                                'Ингредиент',
                                style: TextStyle(color: colors[0]),
                              ),
                            ),
                            // Заметка по секции (необязательно)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                                bottom: 4,
                              ),
                              child: TextField(
                                controller: section.notesController,
                                maxLines: 2,
                                minLines: 1,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Заметка к секции (опционально)',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            },
          ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionPicker extends StatelessWidget {
  final Function(SectionType) onSelect;
  final VoidCallback onCreateCustom;
  final List<SectionType> customTypes;
  final Function(SectionType)? onEditCustom;
  final Function(SectionType)? onDeleteCustom;
  const _SectionPicker({
    required this.onSelect,
    required this.onCreateCustom,
    required this.customTypes,
    this.onEditCustom,
    this.onDeleteCustom,
  });

  Widget _chip(
    SectionType type,
    BuildContext context, {
    bool isCustom = false,
  }) {
    return GestureDetector(
      onTap: () => onSelect(type),
      onLongPress: isCustom
          ? () => _showCustomActions(context, type)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF3A2A2A)
              : const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFF6B8A).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              type.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (isCustom) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.edit,
                size: 12,
                color: Colors.grey.shade500,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCustomActions(BuildContext context, SectionType type) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('${type.icon} ${type.name}'),
        content: const Text('Кастомный тип секции'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onDeleteCustom != null) onDeleteCustom!(type);
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onEditCustom != null) onEditCustom!(type);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B8A),
            ),
            child: const Text('Изменить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите секцию',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              ...SectionType.presets.map((t) => _chip(t, context)),
              ...customTypes.map((t) => _chip(t, context, isCustom: true)),
              GestureDetector(
                onTap: onCreateCustom,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFF6B8A),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 18,
                        color: Color(0xFFE85D75),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Свой тип',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE85D75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionInput {
  final SectionType type;
  final List<_IngredientInput> ingredients = [];
  final TextEditingController notesController;
  _SectionInput({required this.type, String notes = ''})
    : notesController = TextEditingController(text: notes);
}

class _IngredientInput {
  // Не final: при использовании Autocomplete его внутренний controller
  // подменяет наш — так его текст автоматически попадает в save().
  TextEditingController nameController;
  final TextEditingController amountController;
  _IngredientInput({String name = '', String amount = ''})
    : nameController = TextEditingController(text: name),
      amountController = TextEditingController(text: amount);
}
