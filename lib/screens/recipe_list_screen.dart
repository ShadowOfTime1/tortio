import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';
import 'add_recipe_screen.dart';
import 'scaler_screen.dart';

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
  }

  void _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (e) {
      if (mounted) setState(() => _version = '?');
    }
  }

  void _loadRecipes() async {
    final recipes = await StorageService.loadRecipes();
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

  void _confirmDelete(Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Удалить рецепт?'),
        content: Text('«${recipe.title}» будет удалён.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _recipes.removeWhere((r) => r.id == recipe.id));
              _saveRecipes();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Удалить'),
          ),
        ],
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
                  Column(
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
    if (_searchQuery.isEmpty) return _recipes;
    final q = _searchQuery.toLowerCase();
    return _recipes.where((r) => r.title.toLowerCase().contains(q)).toList();
  }

  Widget _buildList() {
    final visible = _visibleRecipes;
    if (visible.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'По «$_searchQuery» ничего не найдено',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: visible.length,
      itemBuilder: (context, i) {
        final r = visible[i];
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
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🍰', style: TextStyle(fontSize: 24)),
                      ),
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
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => _editRecipe(r),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: Colors.grey.shade500,
                        ),
                        IconButton(
                          onPressed: () => _confirmDelete(r),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red.shade300,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
