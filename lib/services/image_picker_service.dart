import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerService {
  /// Открывает галерею, копирует выбранный файл в `applicationDocumentsDirectory`,
  /// возвращает абсолютный путь к копии. `null` если пользователь отменил.
  /// Копирование нужно потому что путь от image_picker'а — временный.
  static Future<String?> pickAndPersist({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1500);
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last.toLowerCase();
    final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final dest = '${dir.path}/$fileName';
    await File(picked.path).copy(dest);
    return dest;
  }
}
