import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/recipe_list_screen.dart';
import 'services/theme_service.dart';
import 'services/update_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Лочимся в портрет: ни UI не задизайнен под landscape, ни системную
  // подсказку «повернуть» Android тогда не показывает (она перекрывала FAB).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await ThemeService.instance.load();
  runApp(const TortioApp());
}

class TortioApp extends StatelessWidget {
  const TortioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Tortio',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: ThemeService.instance.mode,
          // Заворачиваем всё в AnnotatedRegion, чтобы система рисовала иконки
          // статус-бара контрастно фону: тёмные иконки на светлой теме,
          // светлые на тёмной. Без этого в светлой теме часы/wifi/батарея
          // невидимы (белые на бежевом).
          builder: (context, child) {
            final brightness = Theme.of(context).brightness;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: brightness, // iOS
              ),
              child: child!,
            );
          },
          home: const MainWrapper(),
        );
      },
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  UpdateInfo? _update;
  bool _bannerDismissed = false;
  bool _downloading = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  void _checkUpdate() async {
    final update = await UpdateService.checkForUpdate();
    if (update != null && mounted) {
      // Лёгкий haptic — пользователь почувствует, что что-то появилось
      // на экране, даже если телефон лежит экраном вниз.
      HapticFeedback.lightImpact();
      setState(() => _update = update);
    }
  }

  void _downloadUpdate() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _progress = 0;
    });

    try {
      await UpdateService.downloadAndInstall(_update!.downloadUrl, (progress) {
        if (mounted) setState(() => _progress = progress);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _downloading = false);
        final msg = e is UpdateException
            ? e.message
            : 'Ошибка обновления. Проверьте интернет.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_update != null && !_bannerDismissed)
            SafeArea(
              bottom: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B8A), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B8A).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _downloading ? null : _downloadUpdate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _downloading
                                    ? Icons.downloading
                                    : Icons.system_update,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _downloading
                                          ? 'Скачивание... ${(_progress * 100).toInt()}%'
                                          : 'Версия ${_update!.version} доступна',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (!_downloading)
                                      const Text(
                                        'Нажмите чтобы обновить',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (!_downloading)
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _bannerDismissed = true),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          if (_downloading) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: RecipeListScreen()),
        ],
      ),
    );
  }
}
