// File: lib/admin/master/screens/master_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/screens/master_gambar_kelistrikan_screen.dart';
import 'package:master_gambar/admin/master/screens/master_gambar_optional_screen.dart';
import 'package:master_gambar/admin/master/screens/master_gambar_utama_screen.dart';
import 'package:master_gambar/admin/master/screens/master_jenis_kendaraan_screen.dart';
import 'package:master_gambar/admin/master/screens/master_jenis_varian_screen.dart';
import 'package:master_gambar/admin/master/screens/master_merk_screen.dart';
import 'package:master_gambar/admin/master/screens/master_type_chassis_screen.dart';
import 'package:master_gambar/admin/master/screens/master_type_engine_screen.dart';
import 'package:master_gambar/admin/master/screens/master_varian_body_screen.dart';
import 'package:master_gambar/admin/master/widgets/master_sidebar.dart';

// --- IMPORT DUA HALAMAN BARU ---
import 'package:master_gambar/admin/master/screens/master_data_screen.dart';
import 'package:master_gambar/admin/master/screens/image_status_screen.dart';

class MasterScreen extends ConsumerStatefulWidget {
  const MasterScreen({super.key});

  @override
  ConsumerState<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends ConsumerState<MasterScreen> {
  int _selectedIndex = 0;

  // --- PERBARUI DAFTAR HALAMAN SESUAI URUTAN SIDEBAR (0-10) ---
  final List<Widget> _pages = const [
    // Master Data
    MasterTypeEngineScreen(), // Index 0
    MasterMerkScreen(), // Index 1
    MasterTypeChassisScreen(), // Index 2
    MasterJenisKendaraanScreen(), // Index 3
    MasterDataScreen(), // Index 4 (Halaman baru)
    MasterVarianBodyScreen(), // Index 5
    MasterJenisVarianScreen(), // Index 6
    // Master Gambar
    ImageStatusScreen(), // Index 7 (Halaman laporan)
    MasterGambarUtamaScreen(), // Index 8
    MasterGambarOptionalScreen(), // Index 9
    MasterGambarKelistrikanScreen(), // Index 10
  ];
  // -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Panggil sidebar baru kita
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
