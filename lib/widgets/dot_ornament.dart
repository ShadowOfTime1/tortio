import 'package:flutter/material.dart';

/// Тортово-кондитерский орнамент для фона: иконки cake/cookie/cupcake
/// рассеяны по экрану, лёгкая прозрачность. Заменил скучные точки.
class DotOrnament extends StatelessWidget {
  const DotOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: CustomPaint(
        painter: _CakeOrnamentPainter(
          isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE85D75).withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

class _CakeOrnamentPainter extends CustomPainter {
  final Color color;
  const _CakeOrnamentPainter(this.color);

  // Какие иконки используем — все outlined для лёгкости.
  static const List<IconData> _icons = [
    Icons.cake_outlined,
    Icons.bakery_dining_outlined,
    Icons.cookie_outlined,
    Icons.icecream_outlined,
    Icons.local_cafe_outlined,
  ];

  // (xRel, yRel, size, rotationRad, iconIdx). xRel/yRel — доли ширины/высоты.
  // Фиксированные позиции — узор предсказуемый, не «пляшет» при перерисовке.
  static const List<(double, double, double, double, int)> _placements = [
    (0.10, 0.10, 60.0, -0.20, 0), // cake top-left
    (0.85, 0.18, 50.0, 0.30, 1), // bakery top-right
    (0.15, 0.32, 44.0, 0.10, 2), // cookie
    (0.78, 0.40, 56.0, -0.15, 3), // icecream
    (0.30, 0.55, 50.0, 0.25, 4), // cafe
    (0.85, 0.62, 46.0, -0.30, 0), // cake mid-right
    (0.18, 0.75, 60.0, 0.15, 1), // bakery low-left
    (0.70, 0.82, 50.0, 0.05, 2), // cookie
    (0.40, 0.92, 44.0, -0.20, 3), // icecream bottom
    (0.92, 0.95, 40.0, 0.20, 4), // cafe corner
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _placements) {
      final iconData = _icons[p.$5];
      final x = size.width * p.$1;
      final y = size.height * p.$2;
      final iconSize = p.$3;
      final rot = p.$4;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      final painter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(iconData.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: iconData.fontFamily,
            package: iconData.fontPackage,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(-iconSize / 2, -iconSize / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CakeOrnamentPainter old) => old.color != color;
}
