import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/import_export_service.dart';
import '../services/stats.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../utils.dart';
import 'add_recipe_screen.dart';
import 'scaler_screen.dart';

enum SortOrder { manual, newest, oldest, alpha }

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<Recipe> _recipes = [];
  bool _loaded = false;
  String _version = '...';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTag;
  SortOrder _sortOrder = SortOrder.manual;
  bool _canRestoreImport = false;

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
    _loadVersion();
    _loadSortOrder();
    _refreshRestoreFlag();
  }

  Future<void> _refreshRestoreFlag() async {
    final has = await StorageService.hasImportSnapshot();
    if (!mounted) return;
    setState(() => _canRestoreImport = has);
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
  };

  void _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (e) {
      if (mounted) setState(() => _version = '?');
    }
  }

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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ScalerScreen(recipe: recipe)));
  }

  Future<void> _exportRecipes() async {
    if (_recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нечего экспортировать — список пустой')),
      );
      return;
    }
    try {
      await ImportExportService.exportRecipes(_recipes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка экспорта: $e')));
      }
    }
  }

  Future<void> _importRecipes() async {
    try {
      final count = await ImportExportService.importRecipes();
      if (!mounted) return;
      if (count == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ничего не импортировано')),
        );
      } else {
        await _loadRecipes();
        await _refreshRestoreFlag();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Импортировано: $count. Откатить — через ⋮ меню.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка импорта: битый JSON — $e')),
        );
      }
    }
  }

  void _showStats() {
    final stats = computeStats(_recipes);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.bar_chart_outlined,
                    color: Color(0xFFE85D75),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Статистика',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _statRow('Рецептов', '${stats.recipeCount}'),
              _statRow(
                'Ингредиентов всего',
                '${stats.totalIngredientCount}',
              ),
              if (stats.totalWeight > 0)
                _statRow(
                  'Сумма весов рецептов',
                  formatGrams(stats.totalWeight),
                ),
              const SizedBox(height: 16),
              if (stats.topIngredients.isNotEmpty) ...[
                Text(
                  'ТОП ИНГРЕДИЕНТОВ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ...stats.topIngredients.map(
                  (e) => _statRow(e.key, '×${e.value}'),
                ),
                const SizedBox(height: 12),
              ],
              if (stats.topTags.isNotEmpty) ...[
                Text(
                  'ТОП ТЕГОВ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ...stats.topTags.map(
                  (e) => _statRow(e.key, '×${e.value}'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE85D75),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreImport() async {
    await StorageService.restoreImportSnapshot();
    await _loadRecipes();
    await _refreshRestoreFlag();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Импорт откачен — рецепты восстановлены')),
    );
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
      sections: recipe.sections
          .map(
            (s) => RecipeSection(
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
            ),
          )
          .toList(),
    );
    setState(() => _recipes.add(copy));
    _saveRecipes();
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                    child: const Icon(
                      Icons.cake,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tortio',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'v$_version • Калькулятор рецептов',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: ThemeService.instance,
                    builder: (context, _) => IconButton(
                      tooltip: 'Тема: ${ThemeService.instance.label}',
                      onPressed: () => ThemeService.instance.cycle(),
                      icon: Icon(ThemeService.instance.icon),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Меню',
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) {
                      switch (action) {
                        case 'stats':
                          _showStats();
                        case 'export':
                          _exportRecipes();
                        case 'import':
                          _importRecipes();
                        case 'restore_import':
                          _restoreImport();
                        case 'sort_manual':
                          _setSortOrder(SortOrder.manual);
                        case 'sort_newest':
                          _setSortOrder(SortOrder.newest);
                        case 'sort_oldest':
                          _setSortOrder(SortOrder.oldest);
                        case 'sort_alpha':
                          _setSortOrder(SortOrder.alpha);
                      }
                    },
                    itemBuilder: (_) {
                      Widget sortItem(SortOrder o) => ListTile(
                        leading: Icon(
                          _sortOrder == o
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                        ),
                        title: Text(_sortLabel(o)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                      return [
                        const PopupMenuItem(
                          value: 'stats',
                          child: ListTile(
                            leading: Icon(Icons.bar_chart_outlined),
                            title: Text('Статистика'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'export',
                          child: ListTile(
                            leading: Icon(Icons.upload_file_outlined),
                            title: Text('Экспортировать (JSON)'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'import',
                          child: ListTile(
                            leading: Icon(Icons.download_outlined),
                            title: Text('Импортировать (JSON)'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (_canRestoreImport)
                          const PopupMenuItem(
                            value: 'restore_import',
                            child: ListTile(
                              leading: Icon(Icons.undo, color: Colors.orange),
                              title: Text(
                                'Откатить последний импорт',
                                style: TextStyle(color: Colors.orange),
                              ),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          enabled: false,
                          height: 28,
                          child: Text(
                            'СОРТИРОВКА',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'sort_manual',
                          child: sortItem(SortOrder.manual),
                        ),
                        PopupMenuItem(
                          value: 'sort_newest',
                          child: sortItem(SortOrder.newest),
                        ),
                        PopupMenuItem(
                          value: 'sort_oldest',
                          child: sortItem(SortOrder.oldest),
                        ),
                        PopupMenuItem(
                          value: 'sort_alpha',
                          child: sortItem(SortOrder.alpha),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            if (_loaded && _recipes.length >= 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию',
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
                        onSelected: (_) =>
                            setState(() => _selectedTag = null),
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
                          onSelected: (sel) => setState(
                            () => _selectedTag = sel ? tag : null,
                          ),
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
        ],
      ),
    );
  }

  List<Recipe> get _visibleRecipes {
    final q = _searchQuery.toLowerCase();
    final filtered = _recipes.where((r) {
      if (q.isNotEmpty && !r.title.toLowerCase().contains(q)) return false;
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
    }
    return filtered;
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
    final canReorder = _searchQuery.isEmpty &&
        _selectedTag == null &&
        _sortOrder == SortOrder.manual;

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
            onTap: () => _openRecipe(r),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    gradient[0].withValues(alpha: 0.3),
                    gradient[1].withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: gradient[0].withValues(alpha: 0.3)),
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
                              child: Text(
                                '🍰',
                                style: TextStyle(fontSize: 24),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '⌀ ${r.diameter.round()} см  •  ${r.sections.length} секц.  •  ${r.allIngredients.length} ингр.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
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
                                    color: Colors.black.withValues(
                                      alpha: 0.05,
                                    ),
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
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
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
