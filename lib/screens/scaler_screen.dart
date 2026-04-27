import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/recipe.dart';
import '../models/scaler.dart';
import '../services/app_settings.dart';
import '../services/pdf_export_service.dart';
import '../services/shopping_list.dart';
import '../utils.dart';
import '../widgets/dot_ornament.dart';

enum ScaleMode { size, weight }

class ScalerScreen extends StatefulWidget {
  final Recipe recipe;
  /// Колбэк когда пользователь нажал «Я приготовил» — родитель должен
  /// обновить рецепт в списке (cookCount + lastCookedAt).
  final void Function(Recipe updated)? onRecipeUpdated;

  const ScalerScreen({
    super.key,
    required this.recipe,
    this.onRecipeUpdated,
  });

  @override
  State<ScalerScreen> createState() => _ScalerScreenState();
}

class _ScalerScreenState extends State<ScalerScreen> {
  final _scaler = RecipeScaler();
  late double _newDiameter;
  late double _newHeight; // 0 если высота не указана у рецепта
  late double _newWeight;
  ScaleMode _mode = ScaleMode.size;
  List<int> _quickDiameters = AppSettings.defaultQuickDiameters;
  // Для multi-tier: новые диаметры/высоты по каждому ярусу.
  late List<double> _newTierDiameters;
  late List<double> _newTierHeights;

  late final TextEditingController _diameterController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _newDiameter = widget.recipe.diameter;
    _newHeight = widget.recipe.height; // 0 если не задана
    _newWeight = widget.recipe.weight > 0 ? widget.recipe.weight : 1000;
    _diameterController = TextEditingController(
      text: '${_newDiameter.round()}',
    );
    _heightController = TextEditingController(
      text: _newHeight > 0 ? '${_newHeight.round()}' : '',
    );
    _weightController = TextEditingController(text: '${_newWeight.round()}');
    _newTierDiameters = widget.recipe.allTiers.map((t) => t.diameter).toList();
    _newTierHeights = widget.recipe.allTiers.map((t) => t.height).toList();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final diameters = await AppSettings.loadQuickDiameters();
    final defaultMode = await AppSettings.loadDefaultScaleMode();
    if (!mounted) return;
    setState(() {
      _quickDiameters = diameters;
      // Если у рецепта нет weight'а, режим "по весу" недоступен — игнорим
      // настройку и оставляем size.
      if (defaultMode == 'weight' && widget.recipe.weight > 0) {
        _mode = ScaleMode.weight;
      }
    });
  }

  void _onDiameterSlider(double v) {
    setState(() {
      _newDiameter = v;
      _diameterController.text = '${v.round()}';
    });
  }

  void _onDiameterInput(String v) {
    final parsed = parseNumber(v);
    if (parsed != null && parsed >= 1 && parsed <= 50) {
      setState(() => _newDiameter = parsed);
    }
  }

  void _onHeightSlider(double v) {
    setState(() {
      _newHeight = v;
      _heightController.text = '${v.round()}';
    });
  }

  void _onHeightInput(String v) {
    final parsed = parseNumber(v);
    if (parsed != null && parsed >= 1 && parsed <= 30) {
      setState(() => _newHeight = parsed);
    }
  }

  void _onWeightSlider(double v) {
    setState(() {
      _newWeight = v;
      _weightController.text = '${v.round()}';
    });
  }

  void _onWeightInput(String v) {
    final parsed = parseNumber(v);
    if (parsed != null && parsed >= 1 && parsed <= 20000) {
      setState(() => _newWeight = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recipe.isMultiTier) {
      return _buildMultiTier();
    }
    return _buildSingleTier();
  }

  Widget _buildSingleTier() {
    final recipe = widget.recipe;
    final l = AppLocalizations.of(context);
    final hasWeight = recipe.weight > 0;

    List<RecipeSection> scaled;
    double ratio;

    if (_mode == ScaleMode.weight && hasWeight) {
      scaled = _scaler.scaleByWeight(
        sections: recipe.sections,
        originalWeight: recipe.weight,
        newWeight: _newWeight,
      );
      ratio = _newWeight / recipe.weight;
    } else {
      scaled = _scaler.scaleBySize(
        sections: recipe.sections,
        // Если высота не указана (0) — используем 1 как обычный, тогда
        // height-ratio будет 1 и volume-секции масштабируются как area.
        originalDiameter: recipe.diameter,
        originalHeight: recipe.height > 0 ? recipe.height : 1,
        newDiameter: _newDiameter,
        newHeight: _newHeight > 0 ? _newHeight : null,
      );
      ratio = _newDiameter / recipe.diameter;
    }

    final totalWeight = scaled
        .expand((s) => s.ingredients)
        .fold<double>(0, (sum, i) => sum + i.amount);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DotOrnament()),
          SafeArea(
            child: Column(
              children: [
                // Верхний блок: либо градиент, либо фото-обложка с затемнением.
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: recipe.imagePath.isEmpty
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B8A), Color(0xFFFF8E53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                image: recipe.imagePath.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(recipe.imagePath)),
                        fit: BoxFit.cover,
                        // Затемнение, чтобы белые иконки/текст оставались
                        // читаемыми на любом фото.
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.45),
                          BlendMode.darken,
                        ),
                      )
                    : null,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(
                            context,
                          ).scaler_shopping_list,
                          onPressed: () => _showShoppingList(scaled),
                          icon: const Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(
                            context,
                          ).scaler_cooked_button,
                          onPressed: () => _markCooked(recipe),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                        ),
                        _buildExportMenu(recipe, [scaled], scaled),
                      ],
                    ),
                  ),

                  // Переключатель
                  if (hasWeight)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _modeTab(
                              AppLocalizations.of(context).scaler_title_size,
                              Icons.straighten,
                              ScaleMode.size,
                            ),
                            _modeTab(
                              AppLocalizations.of(context).scaler_title_weight,
                              Icons.scale,
                              ScaleMode.weight,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Контрол
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: _mode == ScaleMode.weight && hasWeight
                        ? _buildWeightControl(recipe)
                        : _buildSizeControl(recipe),
                  ),
                ],
              ),
            ),

            // Бейдж коэффициента + итоговый вес
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (ratio != 1.0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B8A), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '×${ratio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).scaler_total_label,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B8A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).scaler_total_weight(_formatWeight(totalWeight)),
                      style: const TextStyle(
                        color: Color(0xFFE85D75),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Заметки (если есть)
            if (recipe.notes.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFF6B8A).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes,
                        size: 18,
                        color: Color(0xFFE85D75),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          recipe.notes,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Список по секциям
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: scaled.length,
                itemBuilder: (context, si) {
                  final origSection = recipe.sections[si];
                  final scaledSection = scaled[si];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF6B8A,
                            ).withValues(alpha: 0.06),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                scaledSection.type.icon,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                scaledSection.type.displayName(l),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF6B8A,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  scaledSection.type.scaleLabelLocalized(l),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFFF6B8A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...scaledSection.ingredients.asMap().entries.map((
                          entry,
                        ) {
                          final ii = entry.key;
                          final orig = origSection.ingredients[ii];
                          final curr = entry.value;
                          final changed = curr.amount != orig.amount;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    curr.name,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                if (changed)
                                  Text(
                                    '${_formatAmount(orig.amount, orig.unit)}  →  ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  _formatAmount(curr.amount, curr.unit),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: changed
                                        ? const Color(0xFFFF6B8A)
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (scaledSection.notes.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Text(
                              scaledSection.notes,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                                height: 1.3,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  // Делегируем форматирование в utils.formatGrams, прокидывая локализованные
  // единицы — иначе при English-локали всё равно покажутся 'г' / 'кг'.
  String _formatWeight(double g) {
    final l = AppLocalizations.of(context);
    return formatGrams(
      g,
      gramsUnit: l.unit_grams_short,
      kilogramsUnit: l.unit_kilograms_short,
    );
  }

  String _formatAmount(double amount, String unit) {
    final l = AppLocalizations.of(context);
    return formatAmount(
      amount,
      unit,
      gramsUnit: l.unit_grams_short,
      kilogramsUnit: l.unit_kilograms_short,
      piecesUnit: l.unit_pieces_short,
    );
  }

  Widget _buildExportMenu(
    Recipe recipe,
    List<List<RecipeSection>> scaledByTier,
    List<RecipeSection> flatScaled,
  ) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: l.scaler_export_tooltip,
      icon: const Icon(Icons.ios_share, color: Colors.white),
      onSelected: (action) {
        switch (action) {
          case 'share':
            _shareRecipe(recipe, flatScaled);
          case 'pdf':
            _exportPdf(recipe, scaledByTier);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'share',
          child: ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(l.scaler_export_share_text),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l.scaler_export_save_pdf),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  void _markCooked(Recipe recipe) {
    final updated = recipe.markCooked();
    widget.onRecipeUpdated?.call(updated);
    HapticFeedback.lightImpact();
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            updated.cookCount == 1
                ? l.scaler_cooked_first
                : l.scaler_cooked_today(updated.cookCount),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE85D75),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _exportPdf(
    Recipe recipe,
    List<List<RecipeSection>> scaledByTier,
  ) async {
    try {
      await PdfExportService.exportScaledRecipe(
        recipe: recipe,
        scaledByTier: scaledByTier,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).scaler_pdf_error(e.toString()),
          ),
        ),
      );
    }
  }

  /// Scaler-screen для multi-tier рецептов: каждый ярус с собственным
  /// слайдером диаметра и собственными scaled-секциями. Высоты остаются
  /// оригинальными, режим «по весу» отключён (вес — характеристика всего
  /// торта, не отдельных ярусов).
  Widget _buildMultiTier() {
    final recipe = widget.recipe;
    final tiers = recipe.allTiers;

    // Скейлим каждый ярус по новому диаметру и (если задана) высоте.
    final scaledByTier = <List<RecipeSection>>[];
    final ratiosByTier = <double>[];
    for (var i = 0; i < tiers.length; i++) {
      final tier = tiers[i];
      final newD = _newTierDiameters[i];
      final newH = _newTierHeights[i];
      final scaled = _scaler.scaleBySize(
        sections: tier.sections,
        originalDiameter: tier.diameter,
        originalHeight: tier.height > 0 ? tier.height : 1,
        newDiameter: newD,
        newHeight: newH > 0 ? newH : null,
      );
      scaledByTier.add(scaled);
      ratiosByTier.add(newD / tier.diameter);
    }

    // Плоский список секций со всех ярусов — для shopping list и share.
    final flatScaled = scaledByTier.expand((s) => s).toList();

    final totalWeight = flatScaled
        .expand((s) => s.ingredients)
        .fold<double>(0, (sum, i) => sum + i.amount);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DotOrnament()),
          SafeArea(
            child: Column(
              children: [
                // Шапка с фото или градиентом
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: recipe.imagePath.isEmpty
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B8A), Color(0xFFFF8E53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                image: recipe.imagePath.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(recipe.imagePath)),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.45),
                          BlendMode.darken,
                        ),
                      )
                    : null,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(
                            context,
                          ).scaler_shopping_list,
                          onPressed: () => _showShoppingList(flatScaled),
                          icon: const Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(
                            context,
                          ).scaler_cooked_button,
                          onPressed: () => _markCooked(recipe),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                        ),
                        _buildExportMenu(recipe, scaledByTier, flatScaled),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Text(
                        AppLocalizations.of(context).scaler_tiers_total(
                          tiers.length,
                          _formatWeight(totalWeight),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (recipe.notes.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFF6B8A).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes,
                        size: 18,
                        color: Color(0xFFE85D75),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          recipe.notes,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: tiers.length,
                itemBuilder: (context, ti) => _buildTierBlock(
                  ti,
                  tiers[ti],
                  scaledByTier[ti],
                  ratiosByTier[ti],
                ),
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildTierBlock(
    int idx,
    TierData tier,
    List<RecipeSection> scaled,
    double ratio,
  ) {
    final tierWeight = scaled
        .expand((s) => s.ingredients)
        .fold<double>(0, (sum, i) => sum + i.amount);
    final l = AppLocalizations.of(context);
    final label = tier.label.isNotEmpty
        ? l.scaler_tier_label_named(idx + 1, tier.label)
        : l.scaler_tier_label(idx + 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header яруса
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B8A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '×${ratio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE85D75),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              tier.height > 0
                  ? l.scaler_original_size_with_height_weight(
                      l.unit_diameter_symbol,
                      tier.diameter.round(),
                      tier.height.round(),
                      l.unit_centimeters_short,
                      _formatWeight(tierWeight),
                    )
                  : l.scaler_original_size_weight(
                      l.unit_diameter_symbol,
                      tier.diameter.round(),
                      l.unit_centimeters_short,
                      _formatWeight(tierWeight),
                    ),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          // Слайдер диаметра
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.straighten,
                  size: 18,
                  color: Color(0xFFE85D75),
                ),
                Expanded(
                  child: Slider(
                    value: _newTierDiameters[idx].clamp(10, 50),
                    min: 10,
                    max: 50,
                    divisions: 40,
                    label: '${_newTierDiameters[idx].round()} ${l.unit_centimeters_short}',
                    activeColor: const Color(0xFFFF6B8A),
                    onChanged: (v) {
                      setState(() => _newTierDiameters[idx] = v);
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${_newTierDiameters[idx].round()} ${l.unit_centimeters_short}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE85D75),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Слайдер высоты (если у яруса задана)
          if (tier.height > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 22,
                    child: Text(
                      l.scaler_height_label_short,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE85D75),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _newTierHeights[idx].clamp(2, 30),
                      min: 2,
                      max: 30,
                      divisions: 28,
                      label: '${_newTierHeights[idx].round()} ${l.unit_centimeters_short}',
                      activeColor: const Color(0xFFFF6B8A),
                      onChanged: (v) {
                        setState(() => _newTierHeights[idx] = v);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${_newTierHeights[idx].round()} ${l.unit_centimeters_short}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE85D75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          // Секции яруса
          ...scaled.asMap().entries.map((e) {
            final si = e.key;
            final scaledSection = e.value;
            final origSection = tier.sections[si];
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        scaledSection.type.icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        scaledSection.type.displayName(l),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...scaledSection.ingredients.asMap().entries.map((ie) {
                    final ii = ie.key;
                    final curr = ie.value;
                    final orig = origSection.ingredients[ii];
                    final changed = curr.amount != orig.amount;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              curr.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          if (changed)
                            Text(
                              '${_formatAmount(orig.amount, orig.unit)} → ',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            _formatAmount(curr.amount, curr.unit),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: changed
                                  ? const Color(0xFFFF6B8A)
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (scaledSection.notes.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        scaledSection.notes,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showShoppingList(List<RecipeSection> scaled) {
    final l = AppLocalizations.of(context);
    final items = aggregateIngredients(scaled)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    // Считаем итог только по граммам (штуки нельзя сложить с граммами).
    final totalG = items
        .where((e) => e.unit == 'г')
        .fold<double>(0, (sum, e) => sum + e.amount);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shopping_basket_outlined,
                    color: Color(0xFFE85D75),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.scaler_shopping_list_title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (totalG > 0)
                    Text(
                      l.scaler_shopping_list_total(_formatWeight(totalG)),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l.scaler_shopping_list_empty,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (_, i) {
                      final e = items[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.name,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Text(
                              _formatAmount(e.amount, e.unit),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE85D75),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareRecipe(Recipe recipe, List<RecipeSection> scaled) {
    final buf = StringBuffer();
    buf.writeln('🍰 ${recipe.title}');

    final dimensions = <String>[
      '⌀ ${recipe.diameter.round()} см',
      if (recipe.height > 0) 'высота ${recipe.height.round()} см',
    ];
    final totalWeight = scaled
        .expand((s) => s.ingredients)
        .fold<double>(0, (sum, i) => sum + i.amount);
    if (totalWeight > 0) dimensions.add('~${_formatWeight(totalWeight)}');
    buf.writeln(dimensions.join(' • '));
    buf.writeln();

    for (final section in scaled) {
      final ingredients = section.ingredients
          .where((i) => i.name.trim().isNotEmpty)
          .toList();
      if (ingredients.isEmpty) continue;
      buf.writeln('${section.type.icon} ${section.type.name}');
      for (final ing in ingredients) {
        buf.writeln('  • ${ing.name} — ${formatAmount(ing.amount, ing.unit)}');
      }
      buf.writeln();
    }

    if (recipe.notes.trim().isNotEmpty) {
      buf.writeln('📝 Заметки');
      buf.writeln(recipe.notes.trim());
    }

    SharePlus.instance.share(
      ShareParams(text: buf.toString().trim(), subject: recipe.title),
    );
  }

  Widget _modeTab(String label, IconData icon, ScaleMode mode) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? const Color(0xFFFF6B8A) : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xFFFF6B8A) : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeControl(Recipe recipe) {
    final sizeRatio = _newDiameter / recipe.diameter;
    return Column(
      children: [
        // Круг + поле ввода
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40 + (sizeRatio * 40),
              height: 40 + (sizeRatio * 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Text(
                  '⌀',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Поле ввода
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _diameterController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B8A),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixText: AppLocalizations.of(
                    context,
                  ).unit_centimeters_short,
                  suffixStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _onDiameterInput,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Builder(
          builder: (context) {
            final l = AppLocalizations.of(context);
            return Text(
              recipe.height > 0
                  ? l.scaler_original_size_with_height(
                      l.unit_diameter_symbol,
                      recipe.diameter.round(),
                      recipe.height.round(),
                      l.unit_centimeters_short,
                    )
                  : l.scaler_original_size(
                      l.unit_diameter_symbol,
                      recipe.diameter.round(),
                      l.unit_centimeters_short,
                    ),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            );
          },
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _newDiameter.clamp(10, 50),
            min: 10,
            max: 50,
            divisions: 40,
            label: '${_newDiameter.round()} ${AppLocalizations.of(context).unit_centimeters_short}',
            onChanged: _onDiameterSlider,
          ),
        ),
        if (recipe.height > 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                AppLocalizations.of(context).scaler_height_label_full,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B8A),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixText: AppLocalizations.of(
                      context,
                    ).unit_centimeters_short,
                    suffixStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _onHeightInput,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _newHeight.clamp(2, 30),
                    min: 2,
                    max: 30,
                    divisions: 28,
                    label: '${_newHeight.round()} ${AppLocalizations.of(context).unit_centimeters_short}',
                    onChanged: _onHeightSlider,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        // Быстрые кнопки для частых диаметров форм (настраиваются в Settings)
        Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: _quickDiameters.map((d) {
            final selected = _newDiameter.round() == d;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _onDiameterSlider(d.toDouble());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$d',
                  style: TextStyle(
                    color: selected ? const Color(0xFFE85D75) : Colors.white,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeightControl(Recipe recipe) {
    return Column(
      children: [
        // Иконка + поле ввода
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2.5,
                ),
              ),
              child: const Center(
                child: Icon(Icons.scale, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B8A),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixText: AppLocalizations.of(context).unit_grams_short,
                  suffixStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _onWeightInput,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(
            context,
          ).scaler_original_weight(_formatWeight(recipe.weight)),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _newWeight.clamp(100, 20000),
            min: 100,
            max: 20000,
            divisions: 199,
            label: _formatWeight(_newWeight),
            onChanged: _onWeightSlider,
          ),
        ),
      ],
    );
  }
}
