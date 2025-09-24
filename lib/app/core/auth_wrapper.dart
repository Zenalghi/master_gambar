// File: lib/app/core/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../elements/auth/presentation/login_screen.dart';
import '../../elements/home/home_screen.dart';
import 'providers.dart'; // Import file providers

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan provider pengecekan awal
    final authState = ref.watch(initialAuthProvider);

    return authState.when(
      data: (token) {
        if (token != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const Scaffold(body: Center(child: Text('Error'))),
    );
  }
}