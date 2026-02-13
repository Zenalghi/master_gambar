// File: lib/admin/master/widgets/recycle_bin/master_data_recycle_bin.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../models/master_data.dart';
import '../../repository/master_data_repository.dart';

class MasterDataRecycleBin extends ConsumerStatefulWidget {
  const MasterDataRecycleBin({super.key});

  @override
  ConsumerState<MasterDataRecycleBin> createState() =>
      _MasterDataRecycleBinState();
}

class _MasterDataRecycleBinState extends ConsumerState<MasterDataRecycleBin> {
  bool _isLoading = true;
  List<MasterData> _deletedItems = [];
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
          .getDeletedMasterData(search: _searchQuery);
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
          'Semua data Master Data di recycle bin akan dihapus permanen.\n'
          'Data yang terkait dengan Varian Body tidak akan dihapus demi keamanan.',
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
          .emptyTrashMasterData();

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
      await ref.read(masterDataRepositoryProvider).restoreMasterData(id);
      await _fetchTrash();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master Data berhasil dipulihkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memulihkan data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _forceDelete(int id) async {
    try {
      await ref.read(masterDataRepositoryProvider).forceDeleteMasterData(id);
      await _fetchTrash();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master Data dihapus permanen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        final message =
            e.response?.data['errors']?['general']?[0] ??
            'Gagal menghapus data';
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
          const Text('Recycle Bin - Master Data'),
          // --- SEARCH BAR ---
          SizedBox(
            width: 250, // Sedikit dilebarkan karena kombinasinya panjang
            height: 35,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Engine, Merk, Chassis...',
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
        width: 800, // Diperlebar agar nama kombinasi tidak terpotong parah
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
                  final dateStr = item.updatedAt != null
                      ? DateFormat(
                          'dd/MM/yyyy HH:mm:ss',
                        ).format(item.updatedAt!.toLocal())
                      : 'Unknown';

                  // Menggabungkan string kombinasi agar jelas dibaca
                  final kombinasiName =
                      '${item.typeEngine.name} / ${item.merk.name} / ${item.typeChassis.name} / ${item.jenisKendaraan.name}';

                  return ListTile(
                    title: Text(
                      kombinasiName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text('ID: ${item.id} | Dihapus: $dateStr'),
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
