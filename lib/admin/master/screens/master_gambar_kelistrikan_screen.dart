// File: lib/admin/master/screens/master_gambar_kelistrikan_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
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

  // Handler Upload sekarang menerima masterDataId (int) dan File? (nullable)
  void _handleUpload(int masterDataId, String deskripsi, File? file) async {
    setState(() => _isUploading = true);
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addGambarKelistrikan(
            masterDataId: masterDataId,
            deskripsi: deskripsi,
            gambarKelistrikanFile: file,
          );

      // Refresh tabel setelah sukses
      ref.invalidate(gambarKelistrikanFilterProvider);

      // Reset data copy-paste agar form kembali bersih/tertutup
      // ref.read(initialKelistrikanDataProvider.notifier).state = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar Kelistrikan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.response?.data['message'] ?? e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cek apakah ada data "lemparan" dari Master Data
    final initialData = ref.watch(initialKelistrikanDataProvider);

    // Jika ada data lemparan, form harus terbuka otomatis
    final bool shouldExpand = initialData != null;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              const Text(
                'Manajemen Gambar Kelistrikan',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: Icon(Icons.search),
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
          const SizedBox(height: 1),

          ExpansionTile(
            title: const Text(
              'Tambah Gambar Kelistrikan Baru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            maintainState: true,
            // Buka otomatis jika ada data lemparan
            initiallyExpanded: shouldExpand,
            children: [
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                // 2. Teruskan data ke Form
                AddGambarKelistrikanForm(
                  onUpload: _handleUpload,
                  // Ambil key 'masterData' sesuai dengan yang dikirim dari master_data_datasource
                  initialMasterData: initialData?['masterData'] as OptionItem?,
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Expanded(child: GambarKelistrikanTable()),
        ],
      ),
    );
  }
}
