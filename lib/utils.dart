/// Парсит число из строки, принимая и запятую и точку как десятичный
/// разделитель — пользователи в RU-локали по привычке вводят `1,5`.
double? parseNumber(String s) {
  final normalized = s.trim().replaceAll(',', '.');
  return double.tryParse(normalized);
}

/// Форматирует число для отображения. Целые показывает без `.0`. По умолчанию
/// использует запятую (RU-стиль) — для EN-локали передайте `'.'`.
String formatNumber(double v, {String decimalSeparator = ','}) {
  final s = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  return decimalSeparator == '.' ? s : s.replaceAll('.', decimalSeparator);
}

/// Форматирует вес в граммах для отображения: до 1000 г — целые граммы,
/// от 1000 — килограммы с одной десятичной. Единицы и разделитель по
/// умолчанию русские; для других локалей передайте `gramsUnit`,
/// `kilogramsUnit` и `decimalSeparator`. Без BuildContext — чтобы вызывать
/// из shared_text/PDF/share.
String formatGrams(
  double g, {
  String gramsUnit = 'г',
  String kilogramsUnit = 'кг',
  String decimalSeparator = ',',
}) {
  if (g >= 1000) {
    final fixed = (g / 1000).toStringAsFixed(1);
    final localized = decimalSeparator == '.'
        ? fixed
        : fixed.replaceAll('.', decimalSeparator);
    return '$localized $kilogramsUnit';
  }
  return '${g.round()} $gramsUnit';
}

/// Форматирует количество ингредиента с учётом единицы:
/// - storage-unit `'г'` → formatGrams (граммы / килограммы)
/// - storage-unit `'шт'` → целое число штук, штучный round (1.5 → 2)
/// Локализованные единицы и разделитель передаются опционально.
String formatAmount(
  double amount,
  String unit, {
  String gramsUnit = 'г',
  String kilogramsUnit = 'кг',
  String piecesUnit = 'шт',
  String decimalSeparator = ',',
}) {
  if (unit == 'шт') return '${amount.round()} $piecesUnit';
  return formatGrams(
    amount,
    gramsUnit: gramsUnit,
    kilogramsUnit: kilogramsUnit,
    decimalSeparator: decimalSeparator,
  );
}
