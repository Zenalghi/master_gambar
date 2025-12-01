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

  void _handleUpload(
    String typeEngineId,
    String merkId,
    String typeChassisId,
    String deskripsi,
    File file,
  ) async {
    setState(() => _isUploading = true);
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addGambarKelistrikan(
            typeEngineId: typeEngineId,
            merkId: merkId,
            typeChassisId: typeChassisId,
            deskripsi: deskripsi,
            gambarKelistrikanFile: file,
          );

      ref.invalidate(gambarKelistrikanFilterProvider);
      // Reset data copy-paste setelah sukses agar form kembali bersih
      // ref.read(initialKelistrikanDataProvider.notifier).state = null;

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
    // Tonton provider data lemparan
    final initialData = ref.watch(initialKelistrikanDataProvider);

    // Jika ada data, form harus auto-expand
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
                  // Teruskan data awal ke form
                  initialTypeEngine: initialData?['typeEngine'] as OptionItem?,
                  initialMerk: initialData?['merk'] as OptionItem?,
                  initialTypeChassis:
                      initialData?['typeChassis'] as OptionItem?,
                ),
            ],
          ),
          // const Divider(),
          const Expanded(child: GambarKelistrikanTable()),
        ],
      ),
    );
  }
}
