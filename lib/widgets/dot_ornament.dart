import 'package:flutter/material.dart';

/// Лёгкий точечный орнамент в стиле «пергаментной бумаги».
/// Вешается через `Positioned.fill` поверх Scaffold body внутри Stack.
class DotOrnament extends StatelessWidget {
  const DotOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: CustomPaint(
        painter: _DotOrnamentPainter(
          isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE85D75).withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _DotOrnamentPainter extends CustomPainter {
  final Color color;
  const _DotOrnamentPainter(this.color);

  static const double _spacing = 22.0;
  static const double _radius = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    var rowIdx = 0;
    for (var y = _spacing / 2; y < size.height; y += _spacing) {
      final offsetX = (rowIdx % 2 == 0) ? 0.0 : _spacing / 2;
      for (var x = offsetX + _spacing / 2; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), _radius, paint);
      }
      rowIdx++;
    }
  }

  @override
  bool shouldRepaint(covariant _DotOrnamentPainter old) => old.color != color;
}
