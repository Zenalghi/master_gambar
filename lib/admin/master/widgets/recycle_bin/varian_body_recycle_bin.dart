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

  @override
  void initState() {
    super.initState();
    _fetchTrash();
  }

  Future<void> _fetchTrash() async {
    try {
      final data = await ref
          .read(masterDataRepositoryProvider)
          .getDeletedVarianBodies();
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

  Future<void> _restore(int id) async {
    try {
      await ref.read(masterDataRepositoryProvider).restoreVarianBody(id);
      await _fetchTrash();
      ref.invalidate(varianBodyFilterProvider); // Refresh tabel utama
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
      title: const Text('Recycle Bin - Varian Body'),
      content: SizedBox(
        width: 700, // Lebih lebar karena info master data
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _deletedItems.isEmpty
            ? const Center(child: Text('Sampah kosong'))
            : ListView.separated(
                itemCount: _deletedItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _deletedItems[index];
                  final md = item.masterData;
                  final dateStr = DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(item.updatedAt.toLocal());

                  return ListTile(
                    title: Text(item.name),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
