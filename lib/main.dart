import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_theme.dart';
import 'app/core/auth_wrapper.dart'; // Import wrapper

void main() {
  runApp(
    // Bungkus MyApp dengan ProviderScope agar Riverpod berfungsi
    const ProviderScope(
      child: MyApp(),
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
      home: const AuthWrapper(), // Ganti home menjadi AuthWrapper
    );
  }
}