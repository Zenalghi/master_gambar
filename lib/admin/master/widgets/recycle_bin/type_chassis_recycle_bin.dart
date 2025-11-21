// File: lib/admin/master/widgets/recycle_bin/type_chassis_recycle_bin.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../models/type_chassis.dart';
import '../../providers/master_data_providers.dart';
import '../../repository/master_data_repository.dart';

class TypeChassisRecycleBin extends ConsumerStatefulWidget {
  const TypeChassisRecycleBin({super.key});

  @override
  ConsumerState<TypeChassisRecycleBin> createState() =>
      _TypeChassisRecycleBinState();
}

class _TypeChassisRecycleBinState extends ConsumerState<TypeChassisRecycleBin> {
  bool _isLoading = true;
  List<TypeChassis> _deletedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchTrash();
  }

  Future<void> _fetchTrash() async {
    try {
      final data = await ref
          .read(masterDataRepositoryProvider)
          .getDeletedTypeChassis();
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
      await ref.read(masterDataRepositoryProvider).restoreTypeChassis(id);
      await _fetchTrash(); // Refresh list sampah
      ref.invalidate(
        typeChassisFilterProvider,
      ); // Refresh tabel utama di layar belakang
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Type Chassis berhasil dipulihkan'),
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
      await ref.read(masterDataRepositoryProvider).forceDeleteTypeChassis(id);
      await _fetchTrash();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Type Chassis dihapus permanen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        // Menangkap pesan error validasi dari backend (misal: masih dipakai di Master Data)
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
      title: const Text('Recycle Bin - Type Chassis'),
      content: SizedBox(
        width: 600,
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
                  final dateStr = DateFormat(
                    'dd/MM/yyyy HH:mm:ss',
                  ).format(item.updatedAt.toLocal());

                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Dihapus (terakhir update): $dateStr'),
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
