import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/recipe.dart';
import '../services/custom_types_service.dart';
import '../services/image_picker_service.dart';
import '../services/ingredient_history.dart';
import '../services/storage_service.dart';
import '../utils.dart';
import '../widgets/dot_ornament.dart';

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
  final List<_TierInput> _additionalTiers = [];
  final List<String> _tags = [];
  List<SectionType> _customTypes = [];
  List<String> _ingredientSuggestions = const [];
  String _imagePath = '';
  int _rating = 0;
  final ScrollController _scrollController = ScrollController();
  bool get _isEditing => widget.existingRecipe != null;
  // Грязный флаг для подтверждения «Несохранённые изменения. Выйти?» при back.
  bool _isDirty = false;
  void _markDirty() {
    if (!_isDirty) _isDirty = true;
  }

  /// Раскрываем «Дополнительно» при редактировании, если что-то заполнено.
  /// Для нового рецепта — всегда свёрнуто.
  bool get _hasAdvancedData {
    final r = widget.existingRecipe;
    if (r == null) return false;
    return r.weight > 0 ||
        r.notes.isNotEmpty ||
        r.rating > 0 ||
        r.tags.isNotEmpty;
  }

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
      text: r != null ? formatNumber(r.diameter) : '20',
    );
    _heightController = TextEditingController(
      // Высота опциональна. Если у рецепта высота 0 (или новый рецепт) —
      // оставляем поле пустым, пользователь решит сам.
      text: r != null && r.height > 0 ? formatNumber(r.height) : '',
    );
    _weightController = TextEditingController(
      text: r != null && r.weight > 0 ? formatNumber(r.weight) : '',
    );
    _notesController = TextEditingController(text: r?.notes ?? '');
    _tagInputController = TextEditingController();
    if (r != null) _tags.addAll(r.tags);
    _imagePath = r?.imagePath ?? '';
    _rating = r?.rating ?? 0;
    _loadCustomTypes();
    _loadIngredientHistory();
    if (r != null) {
      for (final section in r.sections) {
        _sections.add(_sectionToInput(section));
      }
      for (final tier in r.additionalTiers) {
        final tierInput = _TierInput(
          diameter: formatNumber(tier.diameter),
          height: tier.height > 0 ? formatNumber(tier.height) : '',
          label: tier.label,
        );
        for (final s in tier.sections) {
          tierInput.sections.add(_sectionToInput(s));
        }
        _additionalTiers.add(tierInput);
      }
    }
    _attachDirtyListeners();
  }

  void _attachDirtyListeners() {
    for (final c in [
      _titleController,
      _diameterController,
      _heightController,
      _weightController,
      _notesController,
    ]) {
      c.addListener(_markDirty);
    }
    for (final s in _sections) {
      _attachSectionListeners(s);
    }
    for (final t in _additionalTiers) {
      _attachTierListeners(t);
    }
  }

  void _attachSectionListeners(_SectionInput s) {
    s.notesController.addListener(_markDirty);
    for (final ing in s.ingredients) {
      _attachIngredientListeners(ing);
    }
  }

  void _attachIngredientListeners(_IngredientInput ing) {
    ing.nameController.addListener(_markDirty);
    ing.amountController.addListener(_markDirty);
  }

  void _attachTierListeners(_TierInput t) {
    t.diameterController.addListener(_markDirty);
    t.heightController.addListener(_markDirty);
    t.labelController.addListener(_markDirty);
    for (final s in t.sections) {
      _attachSectionListeners(s);
    }
  }

  _SectionInput _sectionToInput(RecipeSection s) {
    final input = _SectionInput(type: s.type, notes: s.notes);
    for (final ing in s.ingredients) {
      input.ingredients.add(
        _IngredientInput(
          name: ing.name,
          // Для штук — целое число, для граммов — без хвостового «.0».
          amount: ing.unit == 'шт'
              ? '${ing.amount.round()}'
              : formatNumber(ing.amount),
          unit: ing.unit,
        ),
      );
    }
    return input;
  }

  Future<void> _loadCustomTypes() async {
    final types = await CustomTypesService.load();
    if (mounted) setState(() => _customTypes = types);
  }

  Future<void> _loadIngredientHistory() async {
    final all = await StorageService.loadRecipes();
    if (mounted) {
      setState(() => _ingredientSuggestions = ingredientHistory(all));
    }
  }

  void _addSection({List<_SectionInput>? toList}) {
    final target = toList ?? _sections;
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
          final s = _SectionInput(type: type);
          _attachSectionListeners(s);
          _markDirty();
          setState(() => target.add(s));
        },
        onCreateCustom: () async {
          Navigator.pop(ctx);
          final created = await _showCreateCustomTypeDialog();
          if (created != null) {
            final updated = [..._customTypes, created];
            await CustomTypesService.save(updated);
            if (mounted) {
              final s = _SectionInput(type: created);
              _attachSectionListeners(s);
              _markDirty();
              setState(() {
                _customTypes = updated;
                target.add(s);
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
            initial == null
                ? AppLocalizations.of(ctx).custom_type_dialog_new
                : AppLocalizations.of(ctx).custom_type_dialog_edit,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).custom_type_field_name,
                  hintText: AppLocalizations.of(
                    ctx,
                  ).custom_type_field_name_hint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: iconController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx).custom_type_field_icon,
                  hintText: '🍡',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(ctx).custom_type_field_scale_label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              RadioGroup<ScaleType>(
                groupValue: selectedScale,
                onChanged: (v) => setDialogState(() => selectedScale = v!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppLocalizations.of(ctx).custom_type_scale_volume,
                      ),
                      value: ScaleType.volume,
                    ),
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppLocalizations.of(ctx).custom_type_scale_area,
                      ),
                      value: ScaleType.area,
                    ),
                    RadioListTile<ScaleType>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppLocalizations.of(ctx).custom_type_scale_fixed,
                      ),
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
              child: Text(AppLocalizations.of(ctx).common_cancel),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final icon = iconController.text.trim();
                if (name.isEmpty || icon.isEmpty) return;
                Navigator.pop(
                  ctx,
                  SectionType(name: name, icon: icon, scaleType: selectedScale),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B8A),
              ),
              child: Text(
                initial == null
                    ? AppLocalizations.of(ctx).custom_type_create
                    : AppLocalizations.of(ctx).common_save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addIngredient(_SectionInput section) {
    final ing = _IngredientInput();
    _attachIngredientListeners(ing);
    _markDirty();
    setState(() => section.ingredients.add(ing));
  }

  void _removeIngredient(_SectionInput section, int ingIndex) {
    _markDirty();
    setState(() => section.ingredients.removeAt(ingIndex));
  }

  void _removeSectionFrom(List<_SectionInput> list, _SectionInput section) {
    _markDirty();
    setState(() => list.remove(section));
  }

  void _addTier() {
    // Дефолт нового яруса = размер предыдущего минус 4 см диаметра (типичный
    // step для свадебных тортов), та же высота. Поля editable как обычно.
    double prevD;
    double prevH;
    if (_additionalTiers.isEmpty) {
      prevD = parseNumber(_diameterController.text) ?? 20;
      prevH = parseNumber(_heightController.text) ?? 10;
    } else {
      final prev = _additionalTiers.last;
      prevD = parseNumber(prev.diameterController.text) ?? 20;
      prevH = parseNumber(prev.heightController.text) ?? 10;
    }
    final newD = (prevD - 4).clamp(10, 50);
    final tier = _TierInput(
      diameter: '${newD.round()}',
      height: '${prevH.round()}',
    );
    _attachTierListeners(tier);
    _markDirty();
    setState(() {
      _additionalTiers.add(tier);
    });
    // Скроллим к новому ярусу после rebuild — иначе пользователь не увидит,
    // что ярус добавился (он внизу формы, ниже видимой области), и думает
    // что кнопка не сработала.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeTier(_TierInput tier) {
    _markDirty();
    setState(() => _additionalTiers.remove(tier));
  }

  /// Чистит секции списка от пустых ингредиентов и пустых секций,
  /// возвращает список `RecipeSection`. Используется для tier 1 и tier 2+.
  List<RecipeSection> _buildCleanSections(List<_SectionInput> list) {
    return list
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
                  unit: ing.unit,
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
    _markDirty();
    setState(() {
      _tags.addAll(newTags);
      _tagInputController.clear();
    });
  }

  void _removeTag(String tag) {
    _markDirty();
    setState(() => _tags.remove(tag));
  }

  void _save() {
    final title = _titleController.text.trim();
    final diameter = parseNumber(_diameterController.text) ?? 0;
    final height = parseNumber(_heightController.text) ?? 0;
    final weight = parseNumber(_weightController.text) ?? 0;
    final l = AppLocalizations.of(context);

    if (title.isEmpty) {
      _showError(l.form_error_title_required);
      return;
    }
    if (diameter <= 0) {
      _showError(l.form_error_diameter_required);
      return;
    }
    // Высота теперь опциональна. Если 0 — скейлер сделает только по площади
    // (объёмные секции масштабируются как area).
    if (_sections.isEmpty) {
      _showError(l.form_error_no_sections);
      return;
    }

    // Чистим: пустые ингредиенты (без имени или вес ≤ 0) и пустые секции
    // дропаются. Если после очистки tier 1 пустой — ошибка. Tier 2+ просто
    // отбрасываются если пустые.
    final cleanSections = _buildCleanSections(_sections);

    if (cleanSections.isEmpty) {
      _showError(l.form_error_no_ingredients);
      return;
    }

    final additionalTiers = <TierData>[];
    final droppedTierNumbers = <int>[];
    for (var i = 0; i < _additionalTiers.length; i++) {
      final t = _additionalTiers[i];
      final tierNumber = i + 2; // ярус 2, 3, ...
      final tierD = parseNumber(t.diameterController.text) ?? 0;
      final tierH = parseNumber(t.heightController.text) ?? 0;
      if (tierD <= 0) {
        droppedTierNumbers.add(tierNumber);
        continue;
      }
      // Высота яруса опциональна.
      final tierSections = _buildCleanSections(t.sections);
      if (tierSections.isEmpty) {
        droppedTierNumbers.add(tierNumber);
        continue;
      }
      additionalTiers.add(
        TierData(
          diameter: tierD,
          height: tierH,
          label: t.labelController.text.trim(),
          sections: tierSections,
        ),
      );
    }

    if (droppedTierNumbers.isNotEmpty) {
      _showError(
        l.form_error_tiers_skipped_full(droppedTierNumbers.join(', ')),
      );
      return;
    }

    final existing = widget.existingRecipe;
    final recipe = Recipe(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      diameter: diameter,
      height: height,
      weight: weight,
      notes: _notesController.text.trim(),
      tags: List.unmodifiable(_tags),
      imagePath: _imagePath,
      rating: _rating,
      sections: cleanSections,
      additionalTiers: additionalTiers,
      // Сохраняем личную статистику и закрепление при редактировании.
      // Без этого Save затирал бы их в дефолты (0/0/false).
      cookCount: existing?.cookCount ?? 0,
      lastCookedAt: existing?.lastCookedAt ?? 0,
      pinned: existing?.pinned ?? false,
    );
    _isDirty = false; // успешное сохранение — back больше не должен пугать
    Navigator.of(context).pop(recipe);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final path = await ImagePickerService.pickAndPersist(source: source);
      if (path != null && mounted) {
        _markDirty();
        setState(() => _imagePath = path);
      }
    } catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? l.form_photo_error_camera(e.toString())
                : l.form_photo_error_gallery(e.toString()),
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
              title: Text(AppLocalizations.of(ctx).form_photo_pick),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(AppLocalizations.of(ctx).form_photo_camera),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_imagePath.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  AppLocalizations.of(ctx).form_photo_remove,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _markDirty();
                  setState(() => _imagePath = '');
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Карточка одного дополнительного яруса (ярус 2+).
  /// Tier 1 живёт в основной форме, эти — отдельные складные блоки.
  Widget _buildAdditionalTier(int idx, _TierInput tier) {
    final tierNumber = idx + 2; // 0 → "Ярус 2", 1 → "Ярус 3"
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B8A).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: бейдж "Ярус N" + крестик. Поле названия — отдельной строкой
          // ниже, на всю ширину, иначе hint обрезается.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B8A), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l.form_tier_label(tierNumber),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: l.form_remove_tier,
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _removeTier(tier),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: tier.labelController,
            decoration: InputDecoration(
              hintText: l.form_tier_name_optional,
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          // Размеры
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tier.diameterController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.form_field_diameter,
                    suffixText: l.unit_centimeters_short,
                    isDense: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: tier.heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${l.form_field_height} (${l.common_optional})',
                    suffixText: l.unit_centimeters_short,
                    isDense: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Состав яруса
          Row(
            children: [
              Text(
                l.form_tier_composition,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _addSection(toList: tier.sections),
                icon: const Icon(Icons.add, size: 16),
                label: Text(l.form_section_button),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B8A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSectionsList(tier.sections),
        ],
      ),
    );
  }

  /// Унифицированный рендерер списка секций для любого уровня:
  /// и tier 1 (через _sections), и tier 2+ (через tier.sections).
  /// Включает drag-drop секций, drag-drop ингредиентов, Autocomplete
  /// названий, заметки, empty-state.
  Widget _buildSectionsList(List<_SectionInput> list) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (list.isEmpty)
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
            child: Column(
              children: [
                const Text('🧁', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  l.form_section_empty_title,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  l.form_section_empty_hint,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

        if (list.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: list.length,
            onReorder: (oldIdx, newIdx) {
              _markDirty();
              setState(() {
                if (newIdx > oldIdx) newIdx -= 1;
                final s = list.removeAt(oldIdx);
                list.insert(newIdx, s);
              });
            },
            itemBuilder: (context, si) {
              final section = list[si];
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
                                    section.type.displayName(l),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    l.form_section_scale_label(
                                      section.type.scaleLabelLocalized(l),
                                    ),
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
                              onPressed: () =>
                                  _removeSectionFrom(list, section),
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
                                _markDirty();
                                setState(() {
                                  if (newIdx > oldIdx) newIdx -= 1;
                                  final i = section.ingredients.removeAt(
                                    oldIdx,
                                  );
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
                                        flex: 5,
                                        child: Autocomplete<String>(
                                          initialValue: TextEditingValue(
                                            text: ing.nameController.text,
                                          ),
                                          optionsBuilder: (tev) {
                                            if (tev.text.isEmpty) {
                                              return const Iterable<
                                                String
                                              >.empty();
                                            }
                                            final q = tev.text.toLowerCase();
                                            return _ingredientSuggestions
                                                .where(
                                                  (n) =>
                                                      n.toLowerCase().contains(
                                                        q,
                                                      ) &&
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
                                                  decoration: InputDecoration(
                                                    hintText: l.form_ingredient_hint,
                                                    isDense: true,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: ing.amountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: const InputDecoration(
                                                  hintText: '0',
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            _UnitToggle(
                                              unit: ing.unit,
                                              onChange: (u) {
                                                _markDirty();
                                                setState(() => ing.unit = u);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            _removeIngredient(section, ii),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            TextButton.icon(
                              onPressed: () => _addIngredient(section),
                              icon: Icon(Icons.add, size: 16, color: colors[0]),
                              label: Text(
                                l.form_ingredient_hint,
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
                                  hintText: l.form_section_note_hint,
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
      ],
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

  Future<bool> _confirmDiscard() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.form_unsaved_dialog_title),
        content: Text(l.form_unsaved_dialog_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.form_unsaved_stay),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.form_unsaved_leave),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final discard = await _confirmDiscard();
        if (discard && mounted) navigator.pop();
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? AppLocalizations.of(context).form_title_edit
              : AppLocalizations.of(context).form_title_new,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B8A),
              ),
              child: Text(AppLocalizations.of(context).common_save),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: DotOrnament()),
          SingleChildScrollView(
            controller: _scrollController,
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
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Color(0xFFE85D75),
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).form_photo_label,
                                    style: const TextStyle(
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

                Text(
                  AppLocalizations.of(context).form_field_title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    ).form_field_title_hint,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      AppLocalizations.of(context).form_section_size_header,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context).form_section_size_subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _diameterController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '20',
                          suffixText: AppLocalizations.of(
                            context,
                          ).unit_centimeters_short,
                          labelText: AppLocalizations.of(
                            context,
                          ).form_field_diameter,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).form_field_height_optional,
                          suffixText: AppLocalizations.of(
                            context,
                          ).unit_centimeters_short,
                          labelText: AppLocalizations.of(
                            context,
                          ).form_field_height,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Вес / заметки / оценка / теги — спрятаны под «Дополнительно»
                // чтобы новички не пугались количества полей. При редактировании
                // существующего рецепта с данными — раскрыто автоматически.
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    initiallyExpanded: _hasAdvancedData,
                    title: Text(
                      AppLocalizations.of(context).form_section_extras_header,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context).form_section_extras_subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).form_field_weight_optional_label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '2000',
                          suffixText: AppLocalizations.of(
                            context,
                          ).unit_grams_short,
                          labelText: AppLocalizations.of(
                            context,
                          ).form_field_weight,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context).form_field_notes_label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 5,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).form_field_notes_hint,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context).form_field_rating_label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          ...List.generate(5, (i) {
                            final filled = i < _rating;
                            return IconButton(
                              icon: Icon(
                                filled ? Icons.star : Icons.star_border,
                                color: const Color(0xFFE85D75),
                                size: 28,
                              ),
                              onPressed: () {
                                _markDirty();
                                setState(() {
                                  _rating = (_rating == i + 1) ? 0 : i + 1;
                                });
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                            );
                          }),
                          if (_rating > 0)
                            TextButton(
                              onPressed: () {
                                _markDirty();
                                setState(() => _rating = 0);
                              },
                              child: Text(
                                AppLocalizations.of(context).form_rating_clear,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).form_field_tags_label_optional,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _tagInputController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addTag(),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).form_field_tags_input_hint,
                          helperText: AppLocalizations.of(
                            context,
                          ).form_field_tags_helper,
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
                              backgroundColor: const Color(
                                0xFFFF6B8A,
                              ).withValues(alpha: 0.1),
                              labelStyle: const TextStyle(fontSize: 13),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Секции
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).form_section_composition_header,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _addSection(),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        AppLocalizations.of(context).form_section_button,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B8A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildSectionsList(_sections),
                // Дополнительные ярусы (для многоярусных тортов)
                ..._additionalTiers.asMap().entries.map(
                  (e) => _buildAdditionalTier(e.key, e.value),
                ),
                const SizedBox(height: 8),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _addTier,
                    icon: const Icon(Icons.layers_outlined),
                    label: Text(
                      _additionalTiers.isEmpty
                          ? AppLocalizations.of(context).form_add_tier_first
                          : AppLocalizations.of(context).form_add_tier_more,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE85D75),
                      side: const BorderSide(color: Color(0xFFE85D75)),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
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
      onLongPress: isCustom ? () => _showCustomActions(context, type) : null,
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
              type.displayName(AppLocalizations.of(context)),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (isCustom) ...[
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 12, color: Colors.grey.shade500),
            ],
          ],
        ),
      ),
    );
  }

  void _showCustomActions(BuildContext context, SectionType type) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${type.icon} ${type.displayName(l)}'),
        content: Text(l.form_custom_type_actions_title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onDeleteCustom != null) onDeleteCustom!(type);
            },
            child: Text(
              l.common_delete,
              style: const TextStyle(color: Colors.red),
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
            child: Text(l.common_edit),
          ),
        ],
      ),
    );
  }

  /// Сгруппировано тематически — новичку проще понять, что для чего.
  /// Ключи — внутренние идентификаторы категорий, отображаемое имя берётся
  /// из ARB через `_categoryDisplay`. Имена пресетов («Бисквит» и т.д.) —
  /// data, остаются на русском пока не локализуем сами пресеты.
  static const Map<String, List<String>> _categoryOrder = {
    'base': ['Бисквит', 'Безе'],
    'creams': ['Крем', 'Начинка', 'Мусс'],
    'coatings': ['Покрытие', 'Ганаш', 'Пропитка', 'Глазурь'],
    'decor': ['Декор'],
  };

  String _categoryDisplay(String key, AppLocalizations l) => switch (key) {
    'base' => l.form_section_picker_cat_base,
    'creams' => l.form_section_picker_cat_creams,
    'coatings' => l.form_section_picker_cat_coatings,
    'decor' => l.form_section_picker_cat_decor,
    _ => key,
  };

  List<SectionType> _byCategory(String name) {
    final names = _categoryOrder[name] ?? const [];
    return [
      for (final n in names)
        SectionType.presets.firstWhere(
          (t) => t.name == n,
          orElse: () => SectionType.presets.first,
        ),
    ];
  }

  Widget _categoryHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE85D75),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.form_section_picker_title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          for (final entry in _categoryOrder.entries) ...[
            _categoryHeader(_categoryDisplay(entry.key, l)),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _byCategory(entry.key)
                  .map((t) => _chip(t, context))
                  .toList(),
            ),
          ],
          if (customTypes.isNotEmpty) ...[
            _categoryHeader(l.form_section_picker_custom_group),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: customTypes
                  .map((t) => _chip(t, context, isCustom: true))
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: onCreateCustom,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF6B8A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 18, color: Color(0xFFE85D75)),
                    const SizedBox(width: 6),
                    Text(
                      l.form_section_picker_create_custom,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE85D75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
  String unit; // 'г' или 'шт' — переключается тоглом в форме
  _IngredientInput({String name = '', String amount = '', this.unit = 'г'})
    : nameController = TextEditingController(text: name),
      amountController = TextEditingController(text: amount);
}

/// Доп.ярус (ярус 2+). Tier 1 хранится в root-полях формы.
class _TierInput {
  final TextEditingController diameterController;
  final TextEditingController heightController;
  final TextEditingController labelController;
  final List<_SectionInput> sections = [];

  _TierInput({String diameter = '20', String height = '10', String label = ''})
    : diameterController = TextEditingController(text: diameter),
      heightController = TextEditingController(text: height),
      labelController = TextEditingController(text: label);
}

/// Маленький свитчер «г / шт» в углу поля количества ингредиента.
class _UnitToggle extends StatelessWidget {
  final String unit;
  final ValueChanged<String> onChange;
  const _UnitToggle({required this.unit, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Storage-id ('г'/'шт') стабильный; пользователь видит локализованную метку.
    final display = unit == 'шт' ? l.unit_pieces_short : l.unit_grams_short;
    return InkWell(
      onTap: () => onChange(unit == 'г' ? 'шт' : 'г'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B8A).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          display,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE85D75),
          ),
        ),
      ),
    );
  }
}
