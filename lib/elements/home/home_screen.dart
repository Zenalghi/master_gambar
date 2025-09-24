// File: lib/elements/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/core/providers.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/sidebar.dart';
import 'screens/input_transaksi_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // Definisikan daftar halaman di sini agar tidak dibuat ulang setiap saat
  final List<Widget> _screens = [
    const InputTransaksiScreen(),
    const Scaffold(body: Center(child: Text("Halaman Input Gambar"))),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final tabCount = authService.canViewAdminTabs() ? 3 : 1;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: Row(
          children: [
            Sidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),

            // --- PERUBAHAN UTAMA DI SINI ---
            // Ganti cara menampilkan halaman dengan IndexedStack
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _screens),
            ),
            // ---------------------------------
          ],
        ),
      ),
    );
  }
}
