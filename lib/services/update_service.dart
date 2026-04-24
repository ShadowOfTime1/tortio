import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateException implements Exception {
  final String message;
  UpdateException(this.message);
  @override
  String toString() => message;
}

class UpdateService {
  static const String _owner = 'ShadowOfTime1';
  static const String _repo = 'tortio';

  static Future<UpdateInfo?> checkForUpdate() async {
    // Auto-update механизм работает только на Android (через APK install).
    // На iOS / desktop / web баннер бесполезен — install не сработает.
    if (kIsWeb || !Platform.isAndroid) return null;
    // Уважаем выключатель «Автоматически проверять обновления» из Settings.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('auto_update_check') == false) return null;
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version.trim();

      final url = Uri.parse(
        'https://api.github.com/repos/$_owner/$_repo/releases/latest',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestTag = (data['tag_name'] as String)
            .replaceAll('v', '')
            .trim();
        final downloadUrl = _findApkUrl(data['assets']);

        if (downloadUrl != null && _shouldOfferUpdate(latestTag, currentVersion)) {
          return UpdateInfo(
            version: latestTag,
            downloadUrl: downloadUrl,
            changelog: data['body'] ?? '',
          );
        }
      }
    } catch (e) {
      // Нет интернета — молчим
    }
    return null;
  }

  static Future<void> downloadAndInstall(
    String url,
    void Function(double progress) onProgress,
  ) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/tortio-update.apk';

    await Dio().download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    // Запрашиваем разрешение «Установка из неизвестных источников» ДО открытия APK.
    // Без явного запроса Android 8+ просто отбрасывает в Settings и не возвращает
    // к диалогу установки. После однократного предоставления разрешение запоминается
    // per-source — следующие апдейты пройдут одним тапом.
    if (!await Permission.requestInstallPackages.isGranted) {
      final result = await Permission.requestInstallPackages.request();
      if (!result.isGranted) {
        throw UpdateException(
          'Нужно разрешить установку из неизвестных источников в настройках Android.',
        );
      }
    }

    final result = await OpenFilex.open(
      filePath,
      type: 'application/vnd.android.package-archive',
    );
    if (result.type != ResultType.done) {
      throw UpdateException('Не удалось открыть установщик: ${result.message}');
    }
  }

  static String? _findApkUrl(List<dynamic> assets) {
    for (final asset in assets) {
      if ((asset['name'] as String).endsWith('.apk')) {
        return asset['browser_download_url'];
      }
    }
    return null;
  }

  /// Решает, показывать ли пользователю баннер обновления.
  /// Раньше сравнивали semver — но это не работает при смене схемы версий
  /// (например, переход с v2.7.x → v0.0.1). Теперь любой отличающийся
  /// от установленной версии тег считается «обновлением» — пусть GitHub
  /// решает, какая версия latest, а мы лишь отображаем расхождение.
  static bool _shouldOfferUpdate(String latest, String current) {
    return latest.trim() != current.trim();
  }
}

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String changelog;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.changelog,
  });
}
