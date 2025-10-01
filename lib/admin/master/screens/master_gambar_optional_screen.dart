import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import '../widgets/add_gambar_optional_form.dart'; // Import form baru

class MasterGambarOptionalScreen extends ConsumerStatefulWidget {
  const MasterGambarOptionalScreen({super.key});

  @override
  ConsumerState<MasterGambarOptionalScreen> createState() =>
      _MasterGambarOptionalScreenState();
}

class _MasterGambarOptionalScreenState
    extends ConsumerState<MasterGambarOptionalScreen> {
  bool _isLoading = false;

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
      ref.invalidate(gambarOptionalListProvider);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Gambar Optional',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Panggil widget form di sini
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            AddGambarOptionalForm(onUpload: _handleUpload),

          const SizedBox(height: 24),

          // Di sini nanti akan ada tabel untuk menampilkan data Gambar Optional
          const Divider(),
          const Text(
            'Tabel Data Gambar Optional (akan dibuat)',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
