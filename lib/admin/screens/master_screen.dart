// File: lib/admin/master/screens/master_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
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
import 'package:master_gambar/admin/master/screens/master_data_screen.dart';
import 'package:master_gambar/admin/master/screens/image_status_screen.dart';

class MasterScreen extends ConsumerWidget {
  const MasterScreen({super.key});

  // Daftar halaman sesuai urutan sidebar
  final List<Widget> _pages = const [
    MasterTypeEngineScreen(), // 0
    MasterMerkScreen(), // 1
    MasterTypeChassisScreen(), // 2
    MasterJenisKendaraanScreen(), // 3
    MasterDataScreen(), // 4
    MasterVarianBodyScreen(), // 5
    MasterJenisVarianScreen(), // 6
    ImageStatusScreen(), // 7
    MasterGambarUtamaScreen(), // 8
    MasterGambarOptionalScreen(), // 9
    MasterGambarKelistrikanScreen(), // 10
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Tonton provider navigasi
    final selectedIndex = ref.watch(adminSidebarIndexProvider);

    return Row(
      children: [
        MasterSidebar(
          selectedIndex: selectedIndex,
          onItemSelected: (index) {
            // 2. Update provider saat sidebar diklik manual
            ref.read(adminSidebarIndexProvider.notifier).state = index;
          },
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _pages[selectedIndex]),
      ],
    );
  }
}
