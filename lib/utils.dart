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
String formatGrams(double g) {
  if (g >= 1000) {
    return '${(g / 1000).toStringAsFixed(1).replaceAll('.', ',')} кг';
  }
  return '${g.round()} г';
}

/// Форматирует количество ингредиента с учётом единицы:
/// - 'г' → formatGrams (граммы / килограммы с запятой)
/// - 'шт' → целое число штук, штучный round (1.5 → 2, 0.4 → 0)
String formatAmount(double amount, String unit) {
  if (unit == 'шт') return '${amount.round()} шт';
  return formatGrams(amount);
}
