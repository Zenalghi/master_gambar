import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_theme.dart';
import 'elements/auth/presentation/screens/login_screen.dart'; // Import login screen


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
      debugShowCheckedModeBanner: false,
      title: 'Master Gambar App',
      theme: createAppTheme(),
      home: const LoginScreen(), // Halaman pertama adalah LoginScreen
    );
  }
}