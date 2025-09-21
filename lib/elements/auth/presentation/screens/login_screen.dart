import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Perubahan 1: Buat GlobalKey untuk mengontrol Form
    final _formKey = GlobalKey<FormState>();

    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AsyncValue<void>>(authNotifierProvider, (previous, next) {
      if (next is AsyncError) {
        // Notifikasi error dari server (misal: username/password salah)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (next is AsyncData && previous is AsyncLoading) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Berhasil!")));
        // TODO: Navigasi ke halaman utama setelah login berhasil
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    // Perubahan 2: Bungkus Column dengan Widget Form
                    child: Form(
                      key: _formKey, // Hubungkan Form dengan GlobalKey
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Kolom Username dengan Validator
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(labelText: 'Username'),
                            keyboardType: TextInputType.text,
                            // Perubahan 3: Tambahkan validator
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username tidak boleh kosong';
                              }
                              return null; // Return null jika valid
                            },
                          ),
                          const SizedBox(height: 16.0),

                          // Kolom Password dengan Validator
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Password'),
                            // Perubahan 4: Tambahkan validator
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              return null; // Return null jika valid
                            },
                          ),
                          const SizedBox(height: 24.0),

                          // Tombol Login
                          authState.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  // Perubahan 5: Perbarui logika onPressed
                                  onPressed: () {
                                    // Cek dulu apakah form sudah valid
                                    if (_formKey.currentState!.validate()) {
                                      // Jika valid, baru panggil fungsi login
                                      ref.read(authNotifierProvider.notifier).login(
                                            usernameController.text,
                                            passwordController.text,
                                          );
                                    }
                                  },
                                  child: const Text('Login'),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}