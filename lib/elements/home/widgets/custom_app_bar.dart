// File: lib/elements/home/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/core/providers.dart';
import '../../auth/presentation/screens/login_screen.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Baca role dan nama dari provider masing-masing
    final userRole = ref.watch(userRoleProvider);
    final userName = ref.watch(userNameProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      title: TabBar(
        isScrollable: true,
        tabs: [
          const Tab(text: 'WORK AREA'),
          if (userRole == 'admin') ...[
            const Tab(text: 'MASTER'),
            const Tab(text: 'CONFIGURATION'),
          ],
        ],
      ),
      actions: [
        // --- TAMPILKAN NAMA PENGGUNA DI SINI ---
        // Cek jika nama tidak null sebelum menampilkannya
        if (userName != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(userName, style: const TextStyle(fontSize: 16)),
            ),
          ),
        const VerticalDivider(
          thickness: 1,
          width: 1, // Atur lebar divider
          indent: 12, // Jarak dari atas AppBar
          endIndent: 12, // Jarak dari bawah AppBar
          color: Color.fromARGB(153, 0, 0, 0), // Warna agar sedikit transparan
        ),
        // -----------------------------------------

        // Tombol Logout (tidak berubah)
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            await ref.read(authRepositoryProvider).logout(ref);

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
