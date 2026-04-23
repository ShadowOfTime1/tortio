/// Парсит число из строки, принимая и запятую и точку как десятичный
/// разделитель — пользователи в RU-локали по привычке вводят `1,5`.
double? parseNumber(String s) {
  final normalized = s.trim().replaceAll(',', '.');
  return double.tryParse(normalized);
}
