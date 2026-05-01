import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
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

  String _sortLabel(SortOrder o, AppLocalizations l) => switch (o) {
    SortOrder.manual => l.list_sort_manual,
    SortOrder.newest => l.list_sort_newest,
    SortOrder.oldest => l.list_sort_oldest,
    SortOrder.alpha => l.list_sort_alpha,
    SortOrder.rating => l.list_sort_rating,
    SortOrder.cookedOften => l.list_sort_cook_count,
    SortOrder.cookedRecently => l.list_sort_recently_cooked,
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
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.list_bulk_delete_title(count)),
        content: Text(l.list_bulk_delete_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: Text(l.common_delete),
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
    ).showSnackBar(SnackBar(content: Text(l.list_bulk_deleted(count))));
  }

  void _duplicateRecipe(Recipe recipe) {
    final l = AppLocalizations.of(context);
    final copy = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${recipe.title} ${l.list_recipe_duplicate_suffix}',
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

    final l = AppLocalizations.of(context);
    setState(() => _recipes.removeAt(index));
    _saveRecipes();

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Кастомный content с двумя кнопками: «Отменить» и X. Стандартный
          // `action:` берёт только одну кнопку, а пользователю нужен явный
          // способ закрыть — у некоторых включён accessibility-таймаут,
          // который растягивает duration SnackBar до минут.
          content: Row(
            children: [
              Expanded(
                child: Text(
                  l.list_recipe_named_deleted(recipe.title),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  setState(() => _recipes.insert(index, recipe));
                  _saveRecipes();
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFB3C1),
                ),
                child: Text(l.common_undo),
              ),
              IconButton(
                tooltip: l.common_close,
                onPressed: messenger.hideCurrentSnackBar,
                icon: const Icon(Icons.close, size: 18, color: Colors.white70),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          // Поднимаем над FAB «+ Рецепт» — иначе кнопки «Отменить»/✕
          // попадают в зону FAB, тап перехватывается и undo пропадает.
          // FAB ~56dp + 16dp нижний gap + ~16dp над FAB = ~88dp.
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
          // 6 сек — чтобы пользователь точно успел тапнуть «Отменить»
          // (стандартные 4 сек короткие, особенно если только что отвлёкся).
          duration: const Duration(seconds: 6),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                    hintText: l.list_search_hint,
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
                        label: Text(l.list_filter_all_tags),
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
        label: Text(l.list_fab_new_recipe),
        backgroundColor: const Color(0xFFFF6B8A),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmpty() {
    final l = AppLocalizations.of(context);
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
          Text(
            l.list_empty_title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l.list_empty_subtitle,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _addSampleRecipe,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(l.list_empty_demo_button),
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
    setState(() => _recipes.addAll(buildSampleRecipes(AppLocalizations.of(context))));
    _saveRecipes();
  }

  void _togglePinned(Recipe recipe) {
    final idx = _recipes.indexWhere((r) => r.id == recipe.id);
    if (idx == -1) return;
    setState(() => _recipes[idx] = recipe.togglePinned());
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
    // Закреплённые всегда сверху, поверх любой сортировки.
    filtered.sort((a, b) {
      if (a.pinned == b.pinned) return 0;
      return a.pinned ? -1 : 1;
    });
    return filtered;
  }

  Widget _buildHeader() {
    final l = AppLocalizations.of(context);
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
            tooltip: l.list_tooltip_sort(_sortLabel(_sortOrder, l)),
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
                  title: Text(_sortLabel(o, l)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
          IconButton(
            tooltip: l.list_tooltip_settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader() {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      color: const Color(0xFFFF6B8A).withValues(alpha: 0.12),
      child: Row(
        children: [
          IconButton(
            tooltip: l.list_tooltip_cancel_selection,
            icon: const Icon(Icons.close),
            onPressed: _exitSelection,
          ),
          Expanded(
            child: Text(
              l.list_selection_count(_selectedIds.length),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: l.list_tooltip_delete_selected,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteSelected,
          ),
        ],
      ),
    );
  }

  /// Возвращает читаемый суффикс «· Х дней назад» / «· сегодня» для
  /// последнего приготовления. Пустая строка если lastCookedAt = 0.
  String _lastCookedSuffix(Recipe r, AppLocalizations l) {
    if (r.lastCookedAt == 0) return '';
    final ms = DateTime.now().millisecondsSinceEpoch - r.lastCookedAt;
    final days = ms ~/ (24 * 3600 * 1000);
    if (days == 0) return ' · ${l.time_today}';
    if (days == 1) return ' · ${l.time_yesterday}';
    if (days < 7) return ' · ${l.time_days_ago(days)}';
    if (days < 30) return ' · ${l.time_weeks_ago(days ~/ 7)}';
    if (days < 365) return ' · ${l.time_months_ago(days ~/ 30)}';
    return ' · ${l.time_years_ago(days ~/ 365)}';
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
    final l = AppLocalizations.of(context);
    final visible = _visibleRecipes;
    if (visible.isEmpty) {
      final parts = <String>[];
      if (_searchQuery.isNotEmpty) {
        parts.add(l.list_filter_by_query(_searchQuery));
      }
      if (_selectedTag != null) {
        parts.add(l.list_filter_by_tag(_selectedTag!));
      }
      final desc = parts.isEmpty
          ? l.list_no_results_empty
          : l.list_no_results_filtered(parts.join(' '));
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
                label: Text(l.list_no_results_reset),
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
    // Также отключаем при selection-mode и при наличии закреплённых рецептов
    // (они меняют порядок visible vs _recipes).
    final canReorder =
        _searchQuery.isEmpty &&
        _selectedTag == null &&
        _sortOrder == SortOrder.manual &&
        !_isSelectionMode &&
        !_recipes.any((r) => r.pinned);

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
    final l = AppLocalizations.of(context);
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
                          if (r.pinned) ...[
                            const Icon(
                              Icons.push_pin,
                              size: 14,
                              color: Color(0xFFE85D75),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              r.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.list_card_summary(
                                l.unit_diameter_symbol,
                                r.diameter.round(),
                                l.unit_centimeters_short,
                                r.allTiers.expand((t) => t.sections).length,
                                r.allIngredients.length,
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 13,
                              ),
                              maxLines: 1,
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
                              child: Text(
                                l.list_badge_new,
                                style: const TextStyle(
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
                            const Icon(
                              Icons.star,
                              color: Color(0xFFE85D75),
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${r.rating}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE85D75),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (r.cookCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          l.list_card_cooked(
                            r.cookCount,
                            _lastCookedSuffix(r, l),
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade700,
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
                                color: Colors.black.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
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
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (action) {
                    switch (action) {
                      case 'pin':
                        _togglePinned(r);
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
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'pin',
                      child: ListTile(
                        leading: Icon(
                          r.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: const Color(0xFFE85D75),
                        ),
                        title: Text(
                          r.pinned ? l.list_menu_unpin : l.list_menu_pin,
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(l.list_menu_edit),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: ListTile(
                        leading: const Icon(Icons.copy_outlined),
                        title: Text(l.list_menu_duplicate),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'select',
                      child: ListTile(
                        leading: const Icon(Icons.check_box_outlined),
                        title: Text(l.list_menu_select_bulk),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: Text(
                          l.list_menu_delete,
                          style: const TextStyle(color: Colors.red),
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
