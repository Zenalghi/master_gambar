// File: lib/admin/master/screens/master_gambar_kelistrikan_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
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
  // State untuk melacak proses upload
  bool _isUploading = false;
  void _resetAndRefresh() {
    ref.invalidate(typeEngineListProvider);
    ref.invalidate(merkOptionsFamilyProvider);
    ref.invalidate(typeChassisOptionsFamilyProvider);
    ref.invalidate(jenisKendaraanOptionsFamilyProvider);
    ref.invalidate(varianBodyOptionsFamilyProvider);
    ref.invalidate(gambarOptionalFilterProvider);
    ref
        .read(gambarKelistrikanFilterProvider.notifier)
        .update((state) => Map.from(state));
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  // Method ini akan dipanggil oleh widget form saat tombol upload ditekan
  void _handleUpload(String typeChassisId, String deskripsi, File file) async {
    setState(() => _isUploading = true);
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addGambarKelistrikan(
            typeChassisId: typeChassisId,
            deskripsi: deskripsi,
            gambarKelistrikanFile: file,
          );

      // Refresh tabel data dan provider dropdown (untuk mereset form)
      ref.invalidate(gambarKelistrikanFilterProvider);
      ref.invalidate(typeEngineListProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar Kelistrikan berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.response?.data['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Judul, Search, dan Reload
          Row(
            children: [
              const Text(
                'Manajemen Gambar Kelistrikan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(gambarKelistrikanFilterProvider.notifier)
                        .update((state) => {...state, 'search': value});
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () =>
                    _resetAndRefresh(), // Panggil method reset dan refresh
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Form untuk menambah data (dibungkus ExpansionTile)
          ExpansionTile(
            title: const Text('Tambah Gambar Kelistrikan Baru'),
            initiallyExpanded: true, // Biarkan form terbuka saat pertama kali
            children: [AddGambarKelistrikanForm(onUpload: _handleUpload)],
          ),

          const SizedBox(height: 16),
          // const Divider(),

          // Tabel untuk menampilkan data
          const Expanded(child: GambarKelistrikanTable()),
        ],
      ),
    );
  }
}
