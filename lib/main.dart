import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app/theme/app_theme.dart';
import 'app/core/auth_wrapper.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- 1. Import 'kIsWeb'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- 2. JALANKAN KODE INI HANYA JIKA BUKAN WEB ---
  if (!kIsWeb) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      // size: Size(1280, 720), // Ukuran awal saat aplikasi dibuka
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setMinimumSize(const Size(1280, 720));
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    });
  }
  // ------------------------------------------------

  runApp(const ProviderScope(child: MyApp()));
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
