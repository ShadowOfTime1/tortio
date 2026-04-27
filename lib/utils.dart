/// Парсит число из строки, принимая и запятую и точку как десятичный
/// разделитель — пользователи в RU-локали по привычке вводят `1,5`.
double? parseNumber(String s) {
  final normalized = s.trim().replaceAll(',', '.');
  return double.tryParse(normalized);
}

/// Форматирует число для отображения в RU-локали — точка → запятая.
/// Целые показывает без `.0`. Используется везде в UI вместо прямой
/// интерполяции `${value}`.
String formatNumber(double v) {
  final s = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  return s.replaceAll('.', ',');
}

/// Форматирует вес в граммах для отображения: до 1000 г — целые граммы,
/// от 1000 — килограммы с одной десятичной (RU-стиль с запятой).
/// Единицы по умолчанию русские; если нужны локализованные — передайте
/// `gramsUnit` и `kilogramsUnit`. Сделано так, а не через BuildContext,
/// чтобы функция оставалась чистой и вызывалась из shared_text/PDF/share.
String formatGrams(double g, {String gramsUnit = 'г', String kilogramsUnit = 'кг'}) {
  if (g >= 1000) {
    return '${(g / 1000).toStringAsFixed(1).replaceAll('.', ',')} $kilogramsUnit';
  }
  return '${g.round()} $gramsUnit';
}

/// Форматирует количество ингредиента с учётом единицы:
/// - storage-unit `'г'` → formatGrams (граммы / килограммы)
/// - storage-unit `'шт'` → целое число штук, штучный round (1.5 → 2)
/// Локализованные единицы передаются опционально (по умолчанию русские).
String formatAmount(
  double amount,
  String unit, {
  String gramsUnit = 'г',
  String kilogramsUnit = 'кг',
  String piecesUnit = 'шт',
}) {
  if (unit == 'шт') return '${amount.round()} $piecesUnit';
  return formatGrams(
    amount,
    gramsUnit: gramsUnit,
    kilogramsUnit: kilogramsUnit,
  );
}
