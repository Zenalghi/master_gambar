import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart'; // <-- 1. Import package
import 'app/theme/app_theme.dart';
import 'app/core/auth_wrapper.dart';

// 2. Ubah main menjadi async
void main() async {
  // 3. Pastikan semua binding siap sebelum menjalankan apapun
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi window manager
  await windowManager.ensureInitialized();

  // 4. Atur opsi untuk window Anda
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720), // Ukuran awal saat aplikasi dibuka

    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  // Tunggu hingga window siap untuk ditampilkan, lalu atur propertinya
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // --- 5. INI BAGIAN KUNCINYA: ATUR UKURAN MINIMAL ---
    await windowManager.setMinimumSize(const Size(1280, 720));
    // --------------------------------------------------
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });

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
