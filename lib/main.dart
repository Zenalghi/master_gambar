import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/theme/app_theme.dart';
import 'app/core/auth_wrapper.dart';
import 'package:flutter/foundation.dart'; // Import ini penting untuk kIsWeb dan kReleaseMode
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'app/core/providers.dart';

// Try the provided URLs sequentially and return the first one that is reachable.
Future<String?> _pickWorkingUrl(
  List<String> urls, {
  int timeoutMs = 3000,
}) async {
  final client = HttpClient();
  final timeout = Duration(milliseconds: timeoutMs);
  for (final u in urls) {
    try {
      final uri = Uri.parse(u);
      final request = await client.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      debugPrint('Tried $u -> ${response.statusCode}');
      return u;
    } catch (e) {
      debugPrint('Failed to reach $u: $e');
      continue;
    }
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  // 1. Set Default URL (Bisa untuk fallback)
  String baseUrl = 'http://master-gambar.test/api';

  // 2. Logika Pemisahan Platform
  if (kIsWeb) {
    // === LOGIKA KHUSUS WEB ===
    // Di Web kita tidak bisa baca config.json dari file system lokal.
    // Kita tentukan URL berdasarkan mode build (Debug vs Release/Production)

    if (kReleaseMode) {
      // Jika di-build untuk Production (kantor), pakai IP Server Kantor
      baseUrl = "http://192.168.100.111/master-gambar/public/api";
    } else {
      // Jika sedang Development (Debug), pakai Localhost/Test
      // Catatan: Untuk Android Emulator gunakan 10.0.2.2, untuk Chrome bisa localhost/domain local
      baseUrl = "http://master-gambar.test/api";
    }

    debugPrint("Running on WEB. Base URL: $baseUrl");
  } else {
    // === LOGIKA KHUSUS DESKTOP (WINDOWS) ===
    try {
      String configPath = 'config.json';

      // Ambil path executable hanya jika BUKAN Web
      final appDir = path.dirname(Platform.resolvedExecutable);
      configPath = path.join(appDir, 'config.json');

      final file = File(configPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final config = json.decode(content) as Map<String, dynamic>;

        List<String> urls = [];
        if (config.containsKey('baseUrls') && config['baseUrls'] is List) {
          urls = List<String>.from(config['baseUrls']);
        } else if (config.containsKey('baseUrl') &&
            config['baseUrl'] is String) {
          urls = [config['baseUrl'] as String];
        }

        if (urls.isNotEmpty) {
          int timeoutMs = 3000;
          if (config.containsKey('timeoutMs')) {
            try {
              timeoutMs = (config['timeoutMs'] is int)
                  ? config['timeoutMs'] as int
                  : int.parse('${config['timeoutMs']}');
            } catch (_) {
              debugPrint(
                'Invalid timeoutMs in config, using default $timeoutMs ms',
              );
            }
          }

          final chosen = await _pickWorkingUrl(urls, timeoutMs: timeoutMs);
          if (chosen != null) {
            baseUrl = chosen;
            debugPrint('Selected working baseUrl: $baseUrl');
          } else {
            debugPrint(
              'No reachable URL from config, using first entry as fallback.',
            );
            baseUrl = urls.first;
          }
        }

        debugPrint("Config loaded from $configPath");
      } else {
        debugPrint("Config file not found at $configPath, using default.");
      }
    } catch (e) {
      debugPrint("Error membaca config.json: $e");
      // Fallback url jika config gagal dibaca di desktop
      baseUrl = 'http://localhost/error-url/api';
    }

    // Window Manager hanya untuk Desktop
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1024, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setMinimumSize(const Size(1024, 600));
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final container = ProviderContainer(
    overrides: [baseUrlProvider.overrideWithValue(baseUrl)],
  );
  container.read(darkModeProvider.notifier).state = isDarkMode;

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Rekayasa Desk',
      theme: createAppTheme(darkMode: false),
      darkTheme: createAppTheme(darkMode: true),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            // textScaler: const TextScaler.linear(0.90),
          ),
          child: child!,
        );
      },
      home: const AuthWrapper(),
    );
  }
}
