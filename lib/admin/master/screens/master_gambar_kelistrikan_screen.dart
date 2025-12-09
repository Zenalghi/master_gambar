// File: lib/admin/master/screens/master_gambar_kelistrikan_screen.dart

// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
// import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:master_gambar/data/models/option_item.dart';
import '../widgets/add_gambar_kelistrikan_form.dart';
import '../widgets/gambar_kelistrikan_table.dart';

class MasterGambarKelistrikanScreen extends ConsumerStatefulWidget {
  const MasterGambarKelistrikanScreen({super.key});

  @override
  ConsumerState<MasterGambarKelistrikanScreen> createState() =>
      _MasterGambarKelistrikanScreenState();
}

class _MasterGambarKelistrikanScreenState
    extends ConsumerState<MasterGambarKelistrikanScreen> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Reset filter saat halaman dibuka
    Future.microtask(() {
      ref.invalidate(gambarKelistrikanFilterProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cek apakah ada data "lemparan" dari Master Data (Fitur Copy & Navigate)
    final initialData = ref.watch(initialKelistrikanDataProvider);

    // Jika ada data lemparan, form harus terbuka otomatis
    final bool shouldExpand = initialData != null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER & SEARCH ---
          Row(
            children: [
              const Text(
                'Manajemen File Kelistrikan (Gudang File)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(gambarKelistrikanFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref
                      .read(gambarKelistrikanFilterProvider.notifier)
                      .update((state) => Map.from(state));
                  // Reset data copy-paste saat refresh manual
                  ref.read(initialKelistrikanDataProvider.notifier).state =
                      null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- FORM TAMBAH (EXPANDABLE) ---
          ExpansionTile(
            title: const Text('Upload File Kelistrikan Baru'),
            // Buka otomatis jika ada data lemparan dari Master Data
            initiallyExpanded: shouldExpand,
            children: [
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                // Panggil Widget Form Baru yang sudah disederhanakan
                // Form ini otomatis menangani upload via repository
                AddGambarKelistrikanForm(
                  // Ambil data Type Chassis dari 'initialData' jika ada
                  // Pastikan key-nya sesuai dengan yang dikirim dari master_data_datasource ('typeChassis')
                  initialTypeChassis:
                      initialData?['typeChassis'] as OptionItem?,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // --- TABEL DATA ---
          const Expanded(child: GambarKelistrikanTable()),
        ],
      ),
    );
  }
}
