// File: lib/admin/master/widgets/recycle_bin/varian_body_recycle_bin.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/master/models/varian_body.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';

class VarianBodyRecycleBin extends ConsumerStatefulWidget {
  const VarianBodyRecycleBin({super.key});

  @override
  ConsumerState<VarianBodyRecycleBin> createState() =>
      _VarianBodyRecycleBinState();
}

class _VarianBodyRecycleBinState extends ConsumerState<VarianBodyRecycleBin> {
  bool _isLoading = true;
  List<VarianBody> _deletedItems = [];
  String _searchQuery = ''; // State pencarian
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTrash();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrash() async {
    setState(() => _isLoading = true);
    try {
      final data = await ref
          .read(masterDataRepositoryProvider)
          .getDeletedVarianBodies(search: _searchQuery);
      if (mounted) {
        setState(() {
          _deletedItems = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA KOSONGKAN SAMPAH ---
  Future<void> _emptyTrash() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan Sampah?'),
        content: const Text(
          'Semua data Varian Body di recycle bin akan dihapus permanen.\n'
          'Data yang memiliki Gambar Utama atau Optional tidak akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(masterDataRepositoryProvider)
          .emptyTrashVarianBody();

      await _fetchTrash();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Sampah dikosongkan'),
            backgroundColor: (result['skipped'] ?? 0) > 0
                ? Colors.orange
                : Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _restore(int id) async {
    try {
      await ref.read(masterDataRepositoryProvider).restoreVarianBody(id);
      await _fetchTrash();
      ref.invalidate(varianBodyFilterProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varian Body berhasil dipulihkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _forceDelete(int id) async {
    try {
      await ref.read(masterDataRepositoryProvider).forceDeleteVarianBody(id);
      await _fetchTrash();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varian Body dihapus permanen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        final message =
            e.response?.data['errors']?['general']?[0] ??
            'Gagal menghapus data $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Recycle Bin - Varian Body'),
          // --- SEARCH BAR ---
          SizedBox(
            width: 250,
            height: 35,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Varian / Info Kendaraan...',
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _fetchTrash();
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
                _fetchTrash();
              },
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 700,
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _deletedItems.isEmpty
            ? const Center(child: Text('Sampah kosong / Tidak ditemukan'))
            : ListView.separated(
                itemCount: _deletedItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _deletedItems[index];
                  final md = item.masterData;
                  final dateStr = item.updatedAt != null
                      ? DateFormat(
                          'dd/MM/yyyy HH:mm:ss',
                        ).format(item.updatedAt!.toLocal())
                      : 'Unknown';

                  return ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${md.typeEngine.name} - ${md.merk.name} - ${md.typeChassis.name} - ${md.jenisKendaraan.name}',
                        ),
                        Text(
                          'Dihapus: $dateStr',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          tooltip: 'Pulihkan',
                          onPressed: () => _restore(item.id),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          tooltip: 'Hapus Permanen',
                          onPressed: () => _forceDelete(item.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        // TOMBOL KOSONGKAN SAMPAH
        TextButton.icon(
          onPressed: _deletedItems.isEmpty ? null : _emptyTrash,
          icon: const Icon(Icons.delete_sweep, size: 18),
          label: const Text('Kosongkan Sampah'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),

        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
