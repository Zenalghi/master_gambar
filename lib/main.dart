import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app/theme/app_theme.dart';
import 'app/core/auth_wrapper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'app/core/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String baseUrl;
  try {
    String configPath = 'config.json'; // Path default untuk web/dev

    if (!kIsWeb) {
      // Jika ini aplikasi Windows, cari config.json di sebelah .exe
      final appDir = path.dirname(Platform.resolvedExecutable);
      configPath = path.join(appDir, 'config.json');
    }

    // Baca file secara sinkron (atau asinkron jika Anda lebih suka)
    final file = File(configPath);
    final content = await file.readAsString();
    final config = json.decode(content) as Map<String, dynamic>;
    baseUrl = config['baseUrl'] as String;
  } catch (e) {
    // Fallback jika file config.json tidak ada atau error
    // Anda bisa menampilkan dialog error di sini nanti
    baseUrl = 'http://localhost/error-url/api';
    debugPrint("Error membaca config.json: $e");
  }
  if (!kIsWeb) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 750),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setMinimumSize(const Size(1280, 750));
      await windowManager.maximize();
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ProviderScope(
      overrides: [
        // "Suntikkan" nilai baseUrl yang kita baca dari file
        // ke dalam provider kita.
        baseUrlProvider.overrideWithValue(baseUrl),
      ],
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
      home: const AuthWrapper(),
    );
  }
}
