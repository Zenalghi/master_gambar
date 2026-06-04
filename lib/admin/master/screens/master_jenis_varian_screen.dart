// File: lib/admin/master/screens/master_jenis_varian_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';
import '../widgets/h-jenis_varian/jenis_varian_table.dart';

class MasterJenisVarianScreen extends ConsumerStatefulWidget {
  const MasterJenisVarianScreen({super.key});

  @override
  ConsumerState<MasterJenisVarianScreen> createState() =>
      _MasterJenisVarianScreenState();
}

class _MasterJenisVarianScreenState
    extends ConsumerState<MasterJenisVarianScreen> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // --- RESET OTOMATIS SAAT MASUK HALAMAN ---
    // Mereset search query agar tabel kembali menampilkan semua data
    Future.microtask(() {
      ref.read(jenisVarianSearchQueryProvider.notifier).state = '';
      _searchController.clear();
      ref.invalidate(jenisVarianListProvider);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshJenisVarian() {
    _searchController.clear();
    ref.read(jenisVarianSearchQueryProvider.notifier).state = '';
    ref.invalidate(jenisVarianListProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              const Text(
                'Manajemen Jenis Varian',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(fontSize: 14),
                    labelText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onChanged: (value) =>
                      ref.read(jenisVarianSearchQueryProvider.notifier).state =
                          value,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: _refreshJenisVarian,
              ),
            ],
          ),
          const SizedBox(height: 1),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(fontSize: 14),
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        labelStyle: TextStyle(fontSize: 14),
                        labelText: 'Nama Jenis Varian Baru',
                        hintText: 'Contoh: VARIAN 4',
                      ),
                      //tambahkan validator jika perlu
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama Jenis Varian tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                    ),
                    onPressed: () async {
                      if (_controller.text.trim().isEmpty) return;
                      try {
                        await ref
                            .read(masterDataRepositoryProvider)
                            .addJenisVarian(namaJudul: _controller.text);
                        _controller.clear();
                        ref.invalidate(jenisVarianListProvider);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil ditambahkan'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } on DioException catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${e.response?.data['message'] ?? e.message}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          const Expanded(child: JenisVarianTable()),
        ],
      ),
    );
  }
}
