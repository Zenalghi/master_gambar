//lib\admin\screens\configuration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/widgets/configuration_sidebar.dart';
import '../management/customer_management_screen.dart';
import '../management/user_management_screen.dart';

// 1. Ubah menjadi ConsumerStatefulWidget untuk mengelola state lokal
class ConfigurationScreen extends ConsumerStatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  ConsumerState<ConfigurationScreen> createState() =>
      _ConfigurationScreenState();
}

class _ConfigurationScreenState extends ConsumerState<ConfigurationScreen> {
  // 2. Buat state untuk melacak item sidebar yang dipilih
  int _selectedIndex = 0;

  // 3. Siapkan daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const CustomerManagementScreen(),
    const UserManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 4. Buat layout dengan Row
    return Row(
      children: [
        // Sidebar di sebelah kiri
        ConfigurationSidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Konten di sebelah kanan, akan berubah sesuai pilihan sidebar
        Expanded(child: _pages[_selectedIndex]),
      ],
    );
  }
}
