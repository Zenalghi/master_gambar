import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app/theme/app_theme.dart';
import 'app/core/auth_wrapper.dart';
import 'package:flutter/foundation.dart'; // Import ini penting untuk kIsWeb dan kReleaseMode
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'app/core/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        baseUrl = config['baseUrl'] as String;
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

  runApp(
    ProviderScope(
      overrides: [baseUrlProvider.overrideWithValue(baseUrl)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master Gambar App',
      theme: createAppTheme(),
      debugShowCheckedModeBanner: false,
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
