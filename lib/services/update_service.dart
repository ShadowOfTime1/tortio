import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateService {
  static const String _owner = 'ShadowOfTime1';
  static const String _repo = 'tortio';
  static const String currentVersion = '1.2.0';

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final url = Uri.parse(
        'https://api.github.com/repos/$_owner/$_repo/releases/latest',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestTag = (data['tag_name'] as String).replaceAll('v', '');
        final downloadUrl = _findApkUrl(data['assets']);

        if (downloadUrl != null && _isNewer(latestTag, currentVersion)) {
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

  static String? _findApkUrl(List<dynamic> assets) {
    for (final asset in assets) {
      if ((asset['name'] as String).endsWith('.apk')) {
        return asset['browser_download_url'];
      }
    }
    return null;
  }

  static bool _isNewer(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
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
