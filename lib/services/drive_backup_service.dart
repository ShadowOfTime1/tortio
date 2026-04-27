import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Облачный бэкап рецептов в Google Drive (appDataFolder — скрытая папка
/// приложения, не видна пользователю в UI Drive, не требует Google review).
///
/// Один файл `recipes.json` на пользователя. Last-write-wins по времени
/// модификации (на этой стадии один пользователь — реальных конфликтов нет).
class DriveBackupService extends ChangeNotifier {
  DriveBackupService._();
  static final DriveBackupService instance = DriveBackupService._();

  static const _fileName = 'recipes.json';
  static const _lastSyncKey = 'drive_last_sync_ms';
  // Debounce: после save рецептов ждём, чтобы не аплоадить на каждый
  // keystroke. 20 секунд — компромисс между быстрой защитой и трафиком.
  static const _debounceDelay = Duration(seconds: 20);

  final _signIn = GoogleSignIn(scopes: const [drive.DriveApi.driveAppdataScope]);

  GoogleSignInAccount? _user;
  GoogleSignInAccount? get user => _user;
  bool get isSignedIn => _user != null;

  DateTime? _lastSync;
  DateTime? get lastSync => _lastSync;

  bool _busy = false;
  bool get busy => _busy;

  String? _lastError;
  String? get lastError => _lastError;

  Timer? _debounceTimer;

  /// Вызвать в main() ДО runApp, чтобы при наличии сохранённой сессии
  /// сразу подцепиться к аккаунту без UI.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastSyncKey);
    if (ms != null) _lastSync = DateTime.fromMillisecondsSinceEpoch(ms);

    try {
      _user = await _signIn.signInSilently();
      if (_user != null) notifyListeners();
    } catch (_) {
      // тихо — silent sign-in часто неудачен на первом запуске, это норма
    }
  }

  /// Интерактивный логин (один тап + consent один раз). Возвращает true
  /// если пользователь согласился, false если закрыл диалог.
  Future<bool> signIn() async {
    _setBusy(true);
    try {
      final account = await _signIn.signIn();
      _user = account;
      _lastError = null;
      return account != null;
    } catch (e) {
      _lastError = 'Ошибка входа: $e';
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    _debounceTimer?.cancel();
    await _signIn.signOut();
    _user = null;
    notifyListeners();
  }

  /// Запланировать upload через debounce-таймер. Несколько вызовов подряд
  /// схлопываются в один upload. Если пользователь не залогинен — no-op.
  void scheduleUpload(String jsonContent) {
    if (!isSignedIn) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () => uploadNow(jsonContent));
  }

  /// Принудительный upload прямо сейчас (для кнопки «Синхронизировать»).
  Future<bool> uploadNow(String jsonContent) async {
    if (!isSignedIn) return false;
    _setBusy(true);
    try {
      final api = await _drive();
      if (api == null) return false;

      final existing = await _findBackupFile(api);
      final media = drive.Media(
        Stream.value(utf8.encode(jsonContent)),
        utf8.encode(jsonContent).length,
      );

      if (existing == null) {
        final meta = drive.File()
          ..name = _fileName
          ..parents = ['appDataFolder'];
        await api.files.create(meta, uploadMedia: media);
      } else {
        await api.files.update(drive.File(), existing.id!, uploadMedia: media);
      }
      await _markSynced();
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = 'Ошибка загрузки: $e';
      return false;
    } finally {
      _setBusy(false);
    }
  }

  /// Скачать содержимое recipes.json из бэкапа, или null если бэкапа нет.
  Future<String?> download() async {
    if (!isSignedIn) return null;
    _setBusy(true);
    try {
      final api = await _drive();
      if (api == null) return null;
      final file = await _findBackupFile(api);
      if (file == null) return null;

      final media = await api.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final bytes = <int>[];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }
      _lastError = null;
      return utf8.decode(bytes);
    } catch (e) {
      _lastError = 'Ошибка скачивания: $e';
      return null;
    } finally {
      _setBusy(false);
    }
  }

  /// Метаданные бэкапа (для предложения «Восстановить с N даты?»).
  Future<DateTime?> remoteBackupTime() async {
    if (!isSignedIn) return null;
    try {
      final api = await _drive();
      if (api == null) return null;
      final file = await _findBackupFile(api);
      return file?.modifiedTime;
    } catch (_) {
      return null;
    }
  }

  Future<drive.DriveApi?> _drive() async {
    final client = await _signIn.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  Future<drive.File?> _findBackupFile(drive.DriveApi api) async {
    final list = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_fileName'",
      $fields: 'files(id, name, modifiedTime)',
    );
    final files = list.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  Future<void> _markSynced() async {
    _lastSync = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, _lastSync!.millisecondsSinceEpoch);
    notifyListeners();
  }

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }
}
