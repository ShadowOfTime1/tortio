import 'package:flutter/material.dart';
import '../models/recipe.dart';

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
  final List<_SectionInput> _sections = [];
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
    if (r != null) {
      for (final section in r.sections) {
        final sectionInput = _SectionInput(type: section.type);
        for (final ing in section.ingredients) {
          sectionInput.ingredients.add(
            _IngredientInput(name: ing.name, amount: '${ing.amount}'),
          );
        }
        _sections.add(sectionInput);
      }
    }
  }

  void _addSection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _SectionPicker(
        onSelect: (type) {
          Navigator.pop(ctx);
          setState(() => _sections.add(_SectionInput(type: type)));
        },
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

  void _save() {
    final title = _titleController.text.trim();
    final diameter = double.tryParse(_diameterController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

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

    final recipe = Recipe(
      id:
          widget.existingRecipe?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      diameter: diameter,
      height: height,
      weight: weight,
      notes: _notesController.text.trim(),
      sections: _sections.map((s) {
        return RecipeSection(
          type: s.type,
          ingredients: s.ingredients
              .where((ing) => ing.nameController.text.trim().isNotEmpty)
              .map((ing) {
                return Ingredient(
                  name: ing.nameController.text.trim(),
                  amount: double.tryParse(ing.amountController.text) ?? 0,
                  scaleType: s.type.scaleType,
                );
              })
              .toList(),
        );
      }).toList(),
    );
    Navigator.of(context).pop(recipe);
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

            ..._sections.asMap().entries.map((sEntry) {
              final si = sEntry.key;
              final section = sEntry.value;
              final colors = _sectionColors[si % _sectionColors.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                            ...section.ingredients.asMap().entries.map((
                              iEntry,
                            ) {
                              final ii = iEntry.key;
                              final ing = iEntry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: ing.nameController,
                                        decoration: const InputDecoration(
                                          hintText: 'Ингредиент',
                                          isDense: true,
                                        ),
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
                                      icon: const Icon(Icons.close, size: 16),
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              );
                            }),
                            TextButton.icon(
                              onPressed: () => _addIngredient(si),
                              icon: Icon(Icons.add, size: 16, color: colors[0]),
                              label: Text(
                                'Ингредиент',
                                style: TextStyle(color: colors[0]),
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
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionPicker extends StatelessWidget {
  final Function(SectionType) onSelect;
  const _SectionPicker({required this.onSelect});

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
            children: SectionType.presets.map((type) {
              return GestureDetector(
                onTap: () => onSelect(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionInput {
  final SectionType type;
  final List<_IngredientInput> ingredients = [];
  _SectionInput({required this.type});
}

class _IngredientInput {
  final TextEditingController nameController;
  final TextEditingController amountController;
  _IngredientInput({String name = '', String amount = ''})
    : nameController = TextEditingController(text: name),
      amountController = TextEditingController(text: amount);
}
