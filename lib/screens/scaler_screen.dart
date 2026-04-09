import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/scaler.dart';

enum ScaleMode { size, weight }

class ScalerScreen extends StatefulWidget {
  final Recipe recipe;
  const ScalerScreen({super.key, required this.recipe});

  @override
  State<ScalerScreen> createState() => _ScalerScreenState();
}

class _ScalerScreenState extends State<ScalerScreen> {
  final _scaler = RecipeScaler();
  late double _newDiameter;
  late double _newWeight;
  ScaleMode _mode = ScaleMode.size;

  late final TextEditingController _diameterController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _newDiameter = widget.recipe.diameter;
    _newWeight = widget.recipe.weight > 0 ? widget.recipe.weight : 1000;
    _diameterController = TextEditingController(
      text: '${_newDiameter.round()}',
    );
    _weightController = TextEditingController(text: '${_newWeight.round()}');
  }

  void _onDiameterSlider(double v) {
    setState(() {
      _newDiameter = v;
      _diameterController.text = '${v.round()}';
    });
  }

  void _onDiameterInput(String v) {
    final parsed = double.tryParse(v);
    if (parsed != null && parsed >= 1 && parsed <= 50) {
      setState(() => _newDiameter = parsed);
    }
  }

  void _onWeightSlider(double v) {
    setState(() {
      _newWeight = v;
      _weightController.text = '${v.round()}';
    });
  }

  void _onWeightInput(String v) {
    final parsed = double.tryParse(v);
    if (parsed != null && parsed >= 1 && parsed <= 20000) {
      setState(() => _newWeight = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
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
        originalDiameter: recipe.diameter,
        originalHeight: recipe.height,
        newDiameter: _newDiameter,
      );
      ratio = _newDiameter / recipe.diameter;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Верхний блок
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B8A), Color(0xFFFF8E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
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
                        const SizedBox(width: 48),
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
                              'По размеру',
                              Icons.straighten,
                              ScaleMode.size,
                            ),
                            _modeTab('По весу', Icons.scale, ScaleMode.weight),
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

            // Бейдж коэффициента
            if (ratio != 1.0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
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
                      'пересчёт',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
                      color: Colors.white,
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
                                scaledSection.type.name,
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
                                  scaledSection.type.scaleLabel,
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
                                    '${orig.amount}  →  ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  '${curr.amount} г',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: changed
                                        ? const Color(0xFFFF6B8A)
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  suffixText: 'см',
                  suffixStyle: TextStyle(fontSize: 14, color: Colors.white70),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _onDiameterInput,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Оригинал: ⌀ ${recipe.diameter.round()} см',
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
            value: _newDiameter.clamp(10, 35),
            min: 10,
            max: 35,
            divisions: 25,
            label: '${_newDiameter.round()} см',
            onChanged: _onDiameterSlider,
          ),
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
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  suffixText: 'г',
                  suffixStyle: TextStyle(fontSize: 14, color: Colors.white70),
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
          'Оригинал: ${recipe.weight >= 1000 ? '${(recipe.weight / 1000).toStringAsFixed(1)} кг' : '${recipe.weight.round()} г'}',
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
            value: _newWeight.clamp(100, 10000),
            min: 100,
            max: 10000,
            divisions: 99,
            label: _newWeight >= 1000
                ? '${(_newWeight / 1000).toStringAsFixed(1)} кг'
                : '${_newWeight.round()} г',
            onChanged: _onWeightSlider,
          ),
        ),
      ],
    );
  }
}
