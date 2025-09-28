import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/screens/master_gambar_kelistrikan_screen.dart';
import 'package:master_gambar/admin/master/screens/master_gambar_optional_screen.dart';
import 'package:master_gambar/admin/master/screens/master_gambar_utama_screen.dart';
import 'package:master_gambar/admin/master/screens/master_jenis_kendaraan_screen.dart';
import 'package:master_gambar/admin/master/screens/master_merk_screen.dart';
import 'package:master_gambar/admin/master/screens/master_type_chassis_screen.dart';
import 'package:master_gambar/admin/master/screens/master_type_engine_screen.dart';
import 'package:master_gambar/admin/master/screens/master_varian_body_screen.dart';
import 'package:master_gambar/admin/master/widgets/master_sidebar.dart';

class MasterScreen extends ConsumerStatefulWidget {
  const MasterScreen({super.key});

  @override
  ConsumerState<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends ConsumerState<MasterScreen> {
  int _selectedIndex = 0;

  // Siapkan daftar halaman sesuai urutan di sidebar
  final List<Widget> _pages = const [
    // Master Data
    MasterTypeEngineScreen(),
    MasterMerkScreen(),
    MasterTypeChassisScreen(),
    MasterJenisKendaraanScreen(),
    MasterVarianBodyScreen(),
    // Master Gambar
    MasterGambarUtamaScreen(),
    MasterGambarOptionalScreen(),
    MasterGambarKelistrikanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MasterSidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _pages[_selectedIndex]),
      ],
    );
  }
}
