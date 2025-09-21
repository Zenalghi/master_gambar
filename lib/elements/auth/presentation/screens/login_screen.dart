import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    // Dengarkan perubahan state dari notifier
    ref.listen<AsyncValue<void>>(authNotifierProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
      if (next is AsyncData && previous is AsyncLoading) {
         // Navigasi ke home screen jika sukses
         // Navigator.of(context).pushReplacement(...);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Berhasil!")));
      }
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).login(
                            usernameController.text,
                            passwordController.text,
                          );
                    },
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}