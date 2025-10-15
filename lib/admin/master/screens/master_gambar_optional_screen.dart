import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../widgets/add_gambar_optional_form.dart';
import '../widgets/gambar_optional_table.dart'; // Import form baru

class MasterGambarOptionalScreen extends ConsumerStatefulWidget {
  const MasterGambarOptionalScreen({super.key});

  @override
  ConsumerState<MasterGambarOptionalScreen> createState() =>
      _MasterGambarOptionalScreenState();
}

class _MasterGambarOptionalScreenState
    extends ConsumerState<MasterGambarOptionalScreen> {
  bool _isLoading = false;
  void _resetAndRefresh() {
    //Tambahkan invalidate untuk semua .family
    ref.invalidate(typeEngineListProvider);
    ref.invalidate(merkOptionsFamilyProvider);
    ref.invalidate(typeChassisOptionsFamilyProvider);
    ref.invalidate(jenisKendaraanOptionsFamilyProvider);
    ref.invalidate(varianBodyOptionsFamilyProvider);
    ref.invalidate(gambarOptionalFilterProvider);
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  // Method ini akan dipanggil oleh widget form
  void _handleUpload(int varianBodyId, String deskripsi, File file) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addGambarOptional(
            varianBodyId: varianBodyId,
            deskripsi: deskripsi,
            gambarOptionalFile: file,
          );

      // Refresh tabel data (jika sudah ada) dan provider dropdown
      ref.invalidate(gambarOptionalFilterProvider);
      ref.invalidate(typeEngineListProvider); // Untuk mereset form

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar Optional berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );

      // Di sini Anda bisa menambahkan logika untuk mereset form jika diperlukan
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.response?.data['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Ubah menjadi Padding, bukan SingleChildScrollView
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Gambar Optional',
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
                        .read(gambarOptionalFilterProvider.notifier)
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

          // Form untuk menambah data (sekarang dibungkus ExpansionTile)
          ExpansionTile(
            title: const Text('Tambah Gambar Optional Baru'),
            initiallyExpanded: true,
            children: [AddGambarOptionalForm(onUpload: _handleUpload)],
          ),

          const SizedBox(height: 16),
          // const Divider(),
          // const SizedBox(height: 16),

          // Tabel untuk menampilkan data
          const Expanded(child: GambarOptionalTable()),
        ],
      ),
    );
  }
}
