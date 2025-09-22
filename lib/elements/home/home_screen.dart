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

  @override
  Widget build(BuildContext context) {
    // Baca role langsung dari StateProvider. Tidak perlu .when() lagi.
    final userRole = ref.watch(userRoleProvider);
    final tabCount = (userRole == 'admin') ? 3 : 1;

    // UI utama yang kini dijamin memiliki data role yang benar
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
            Expanded(
              child: [
                const InputTransaksiScreen(),
                const Scaffold(body: Center(child: Text("Halaman Input Gambar"))),
              ][_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}