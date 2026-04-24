import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/sample_recipe.dart';
import '../services/storage_service.dart';
import '../widgets/dot_ornament.dart';
import 'add_recipe_screen.dart';
import 'scaler_screen.dart';
import 'settings_screen.dart';

enum SortOrder { manual, newest, oldest, alpha, rating, cookedOften, cookedRecently }

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<Recipe> _recipes = [];
  bool _loaded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTag;
  SortOrder _sortOrder = SortOrder.manual;
  final Set<String> _selectedIds = {};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  final List<List<Color>> _cardGradients = [
    [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
    [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
    [const Color(0xFFFAD0C4), const Color(0xFFFFD1FF)],
    [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
    [const Color(0xFFF6D365), const Color(0xFFFDA085)],
    [const Color(0xFFFA709A), const Color(0xFFFEE140)],
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadSortOrder();
  }

  Future<void> _loadSortOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sort_order');
    if (!mounted || raw == null) return;
    setState(() {
      _sortOrder = SortOrder.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => SortOrder.manual,
      );
    });
  }

  Future<void> _setSortOrder(SortOrder o) async {
    setState(() => _sortOrder = o);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sort_order', o.name);
  }

  String _sortLabel(SortOrder o) => switch (o) {
    SortOrder.manual => 'Вручную',
    SortOrder.newest => 'Новые сначала',
    SortOrder.oldest => 'Старые сначала',
    SortOrder.alpha => 'По алфавиту',
    SortOrder.rating => 'По рейтингу',
    SortOrder.cookedOften => 'Чаще готовлю',
    SortOrder.cookedRecently => 'Недавно готовил',
  };

  Future<void> _loadRecipes() async {
    final recipes = await StorageService.loadRecipes();
    if (!mounted) return;
    setState(() {
      _recipes = recipes;
      _loaded = true;
    });
  }

  void _saveRecipes() {
    StorageService.saveRecipes(_recipes);
  }

  void _addRecipe() async {
    final recipe = await Navigator.of(
      context,
    ).push<Recipe>(MaterialPageRoute(builder: (_) => const AddRecipeScreen()));
    if (recipe != null) {
      setState(() => _recipes.add(recipe));
      _saveRecipes();
    }
  }

  void _editRecipe(Recipe recipe) async {
    final updated = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(
        builder: (_) => AddRecipeScreen(existingRecipe: recipe),
      ),
    );
    if (updated != null) {
      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        setState(() => _recipes[index] = updated);
        _saveRecipes();
      }
    }
  }

  void _openRecipe(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScalerScreen(
          recipe: recipe,
          onRecipeUpdated: (updated) {
            // Колбэк из «Я приготовил» — обновляем рецепт на месте.
            final idx = _recipes.indexWhere((r) => r.id == updated.id);
            if (idx != -1) {
              setState(() => _recipes[idx] = updated);
              _saveRecipes();
            }
          },
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    // Settings might have изменил рецепты (импорт / удаление / откат) —
    // перезагружаем список после возврата.
    await _loadRecipes();
  }

  void _toggleSelected(Recipe recipe) {
    setState(() {
      if (_selectedIds.contains(recipe.id)) {
        _selectedIds.remove(recipe.id);
      } else {
        _selectedIds.add(recipe.id);
      }
    });
  }

  void _enterSelection(Recipe recipe) {
    setState(() => _selectedIds.add(recipe.id));
  }

  void _exitSelection() {
    setState(_selectedIds.clear);
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Удалить $count рецепт(ов)?'),
        content: const Text(
          'Все выбранные рецепты будут удалены безвозвратно.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _recipes.removeWhere((r) => _selectedIds.contains(r.id));
      _selectedIds.clear();
    });
    _saveRecipes();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Удалено: $count')));
  }

  void _duplicateRecipe(Recipe recipe) {
    final copy = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${recipe.title} (копия)',
      diameter: recipe.diameter,
      height: recipe.height,
      weight: recipe.weight,
      notes: recipe.notes,
      tags: List<String>.from(recipe.tags),
      imagePath: recipe.imagePath,
      rating: recipe.rating,
      // Дубликат — это новый рецепт без истории готовки.
      cookCount: 0,
      lastCookedAt: 0,
      sections: recipe.sections.map(_cloneSection).toList(),
      additionalTiers: recipe.additionalTiers
          .map(
            (t) => TierData(
              diameter: t.diameter,
              height: t.height,
              label: t.label,
              sections: t.sections.map(_cloneSection).toList(),
            ),
          )
          .toList(),
    );
    setState(() => _recipes.add(copy));
    _saveRecipes();
  }

  RecipeSection _cloneSection(RecipeSection s) {
    return RecipeSection(
      type: s.type,
      notes: s.notes,
      ingredients: s.ingredients
          .map(
            (i) => Ingredient(
              name: i.name,
              amount: i.amount,
              scaleType: i.scaleType,
            ),
          )
          .toList(),
    );
  }

  void _deleteWithUndo(Recipe recipe) {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index == -1) return;

    setState(() => _recipes.removeAt(index));
    _saveRecipes();

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('«${recipe.title}» удалён'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () {
              setState(() => _recipes.insert(index, recipe));
              _saveRecipes();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DotOrnament()),
          SafeArea(
            child: Column(
              children: [
                _isSelectionMode ? _buildSelectionHeader() : _buildHeader(),
            if (_loaded && _recipes.length >= 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию или ингредиенту',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),
              ),
            if (_loaded && _allTags.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: FilterChip(
                        label: const Text('Все'),
                        selected: _selectedTag == null,
                        onSelected: (_) => setState(() => _selectedTag = null),
                      ),
                    ),
                    ..._allTags.map(
                      (tag) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: FilterChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (sel) =>
                              setState(() => _selectedTag = sel ? tag : null),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: !_loaded
                  ? const Center(child: CircularProgressIndicator())
                  : _recipes.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
            ),
          ],
        ),
      ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecipe,
        icon: const Icon(Icons.add),
        label: const Text('Рецепт'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B8A).withValues(alpha: 0.15),
                  const Color(0xFFFF8E53).withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Text('🎂', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Пока нет рецептов',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте свой первый торт!',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _addSampleRecipe,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Создать примерный рецепт'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE85D75),
              side: const BorderSide(color: Color(0xFFE85D75)),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSampleRecipe() async {
    setState(() => _recipes.add(buildSampleRecipe()));
    _saveRecipes();
  }

  List<Recipe> get _visibleRecipes {
    final q = _searchQuery.toLowerCase();
    final filtered = _recipes.where((r) {
      if (q.isNotEmpty) {
        final inTitle = r.title.toLowerCase().contains(q);
        final inIngredients = r.allIngredients.any(
          (i) => i.name.toLowerCase().contains(q),
        );
        if (!inTitle && !inIngredients) return false;
      }
      if (_selectedTag != null && !r.tags.contains(_selectedTag)) return false;
      return true;
    }).toList();
    // id рецептов = millisecondsSinceEpoch на момент создания, поэтому
    // лексикографическое сравнение совпадает с хронологическим.
    switch (_sortOrder) {
      case SortOrder.manual:
        return filtered;
      case SortOrder.newest:
        filtered.sort((a, b) => b.id.compareTo(a.id));
      case SortOrder.oldest:
        filtered.sort((a, b) => a.id.compareTo(b.id));
      case SortOrder.alpha:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case SortOrder.rating:
        // Высокие первыми; рецепты без оценки уходят в конец.
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOrder.cookedOften:
        filtered.sort((a, b) => b.cookCount.compareTo(a.cookCount));
      case SortOrder.cookedRecently:
        filtered.sort((a, b) => b.lastCookedAt.compareTo(a.lastCookedAt));
    }
    return filtered;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B8A), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B8A).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.cake, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Tortio',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          PopupMenuButton<SortOrder>(
            tooltip: 'Сортировка: ${_sortLabel(_sortOrder)}',
            icon: const Icon(Icons.swap_vert),
            onSelected: _setSortOrder,
            itemBuilder: (_) => SortOrder.values.map((o) {
              return PopupMenuItem(
                value: o,
                child: ListTile(
                  leading: Icon(
                    _sortOrder == o
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 20,
                  ),
                  title: Text(_sortLabel(o)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
          IconButton(
            tooltip: 'Настройки',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      color: const Color(0xFFFF6B8A).withValues(alpha: 0.12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Отменить выбор',
            icon: const Icon(Icons.close),
            onPressed: _exitSelection,
          ),
          Expanded(
            child: Text(
              'Выбрано: ${_selectedIds.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Удалить выбранные',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteSelected,
          ),
        ],
      ),
    );
  }

  /// Возвращает читаемый суффикс «· Х дней назад» / «· сегодня» для
  /// последнего приготовления. Пустая строка если lastCookedAt = 0.
  String _lastCookedSuffix(Recipe r) {
    if (r.lastCookedAt == 0) return '';
    final ms = DateTime.now().millisecondsSinceEpoch - r.lastCookedAt;
    final days = ms ~/ (24 * 3600 * 1000);
    if (days == 0) return ' · сегодня';
    if (days == 1) return ' · вчера';
    if (days < 7) return ' · $days дн. назад';
    if (days < 30) return ' · ${days ~/ 7} нед. назад';
    if (days < 365) return ' · ${days ~/ 30} мес. назад';
    return ' · ${days ~/ 365} г. назад';
  }

  /// Рецепт «свежий», если создан меньше 24 часов назад.
  /// Recipe.id = millisecondsSinceEpoch на момент создания.
  bool _isFresh(Recipe r) {
    final created = int.tryParse(r.id) ?? 0;
    if (created == 0) return false;
    return DateTime.now().millisecondsSinceEpoch - created < 86400000;
  }

  List<String> get _allTags {
    final set = <String>{};
    for (final r in _recipes) {
      set.addAll(r.tags);
    }
    final list = set.toList()..sort();
    return list;
  }

  Widget _buildList() {
    final visible = _visibleRecipes;
    if (visible.isEmpty) {
      final parts = <String>[];
      if (_searchQuery.isNotEmpty) parts.add('по запросу «$_searchQuery»');
      if (_selectedTag != null) parts.add('с тегом «$_selectedTag»');
      final desc = parts.isEmpty
          ? 'ничего не найдено'
          : 'нет рецептов ${parts.join(' ')}';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                desc,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.filter_alt_off, size: 18),
                label: const Text('Сбросить фильтры'),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedTag = null;
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B8A),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Drag-to-reorder доступен только когда фильтры выключены и сортировка
    // ручная — иначе индексы в видимом списке не соответствуют _recipes.
    // В режиме выбора drag отключён, чтобы long-press не конфликтовал с tap.
    final canReorder =
        _searchQuery.isEmpty &&
        _selectedTag == null &&
        _sortOrder == SortOrder.manual &&
        !_isSelectionMode;

    if (!canReorder) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: visible.length,
        itemBuilder: (context, i) => _buildRecipeCard(visible[i], i),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: visible.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIdx, newIdx) {
        setState(() {
          if (newIdx > oldIdx) newIdx -= 1;
          final item = _recipes.removeAt(oldIdx);
          _recipes.insert(newIdx, item);
        });
        _saveRecipes();
      },
      itemBuilder: (context, i) {
        final r = visible[i];
        return ReorderableDragStartListener(
          key: ValueKey(r.id),
          index: i,
          child: _buildRecipeCard(r, i),
        );
      },
    );
  }

  Widget _buildRecipeCard(Recipe r, int i) {
    final gradient = _cardGradients[i % _cardGradients.length];
    final selected = _selectedIds.contains(r.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelected(r);
          } else {
            _openRecipe(r);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                gradient[0].withValues(alpha: selected ? 1.0 : 0.85),
                gradient[1].withValues(alpha: selected ? 0.9 : 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: selected
                  ? const Color(0xFFE85D75)
                  : gradient[0].withValues(alpha: 0.5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: r.imagePath.isEmpty
                        ? LinearGradient(colors: gradient)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    image: r.imagePath.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(File(r.imagePath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: r.imagePath.isEmpty
                      ? const Center(
                          child: Text('🍰', style: TextStyle(fontSize: 24)),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              r.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isFresh(r)) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE85D75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          if (r.rating > 0) ...[
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                r.rating,
                                (_) => const Icon(
                                  Icons.star,
                                  color: Color(0xFFE85D75),
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '⌀ ${r.diameter.round()} см  •  ${r.sections.length} секц.  •  ${r.allIngredients.length} ингр.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (r.cookCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Готовили ${r.cookCount} раз${_lastCookedSuffix(r)}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (r.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 3,
                          children: r.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        _editRecipe(r);
                      case 'duplicate':
                        _duplicateRecipe(r);
                      case 'select':
                        _enterSelection(r);
                      case 'delete':
                        _deleteWithUndo(r);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Редактировать'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: ListTile(
                        leading: Icon(Icons.copy_outlined),
                        title: Text('Дублировать'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'select',
                      child: ListTile(
                        leading: Icon(Icons.check_box_outlined),
                        title: Text('Выбрать (массовое удаление)'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text(
                          'Удалить',
                          style: TextStyle(color: Colors.red),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
