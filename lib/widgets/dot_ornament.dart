import 'package:flutter/material.dart';

/// Фон с тёплым градиентом + кондитерским орнаментом (cake/bakery/cookie/...).
/// Кладётся через `Positioned.fill` ниже content в Scaffold body Stack.
/// Имя оставлено `DotOrnament` для совместимости — внутри уже не точки.
class DotOrnament extends StatelessWidget {
  const DotOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1A1413), Color(0xFF2D1A22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFFF6F0), Color(0xFFFFDDE5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _CakeOrnamentPainter(
                isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFE85D75).withValues(alpha: 0.14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CakeOrnamentPainter extends CustomPainter {
  final Color color;
  const _CakeOrnamentPainter(this.color);

  static const List<IconData> _icons = [
    Icons.cake_outlined,
    Icons.bakery_dining_outlined,
    Icons.cookie_outlined,
    Icons.icecream_outlined,
    Icons.local_cafe_outlined,
  ];

  // (xRel, yRel, size, rotationRad, iconIdx). Размеры подняты до 70–110px,
  // позиции расставлены пореже — крупный декоративный узор.
  static const List<(double, double, double, double, int)> _placements = [
    (0.10, 0.08, 92.0, -0.20, 0), // cake top-left
    (0.85, 0.16, 78.0, 0.30, 1), // bakery top-right
    (0.20, 0.30, 70.0, 0.10, 2), // cookie
    (0.78, 0.38, 100.0, -0.18, 3), // icecream big
    (0.40, 0.50, 84.0, 0.22, 4), // cafe center
    (0.88, 0.58, 76.0, -0.30, 0), // cake mid-right
    (0.15, 0.65, 110.0, 0.18, 1), // bakery big low-left
    (0.62, 0.74, 80.0, 0.05, 2), // cookie
    (0.30, 0.88, 90.0, -0.20, 3), // icecream bottom
    (0.85, 0.92, 72.0, 0.22, 4), // cafe corner
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
