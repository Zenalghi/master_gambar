// File: lib/admin/master/screens/master_type_chassis_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../widgets/type_chassis_table.dart';
import '../providers/master_data_providers.dart';
import '../repository/master_data_repository.dart';
import '../widgets/recycle_bin/type_chassis_recycle_bin.dart';

class MasterTypeChassisScreen extends ConsumerStatefulWidget {
  const MasterTypeChassisScreen({super.key});
  @override
  ConsumerState<MasterTypeChassisScreen> createState() =>
      _MasterTypeChassisScreenState();
}

class _MasterTypeChassisScreenState
    extends ConsumerState<MasterTypeChassisScreen> {
  final _chassisController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // --- RESET SEARCH & FILTER TYPE CHASSIS ---
    Future.microtask(() => ref.invalidate(typeChassisFilterProvider));
  }

  @override
  void dispose() {
    _chassisController.dispose();
    super.dispose();
  }

  void _submit() async {
    // 1. Validasi Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addTypeChassis(
            // Tidak perlu merkId lagi
            typeChassis: _chassisController.text,
          );
      _chassisController.clear();
      // Refresh tabel via provider filter
      ref
          .read(typeChassisFilterProvider.notifier)
          .update((state) => Map.from(state));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Type Chassis berhasil ditambahkan!'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Type Chassis',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Search Field
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Type Chassis...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => ref
                      .read(typeChassisFilterProvider.notifier)
                      .update((state) => {...state, 'search': value}),
                ),
              ),
              const SizedBox(width: 8),
              // Refresh Button
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref
                      .read(typeChassisFilterProvider.notifier)
                      .update((state) => Map.from(state));
                  ref
                      .read(typeChassisFilterProvider.notifier)
                      .update((state) => {...state, 'search': ''});
                },
              ),
              const SizedBox(width: 8),
              // Recycle Bin Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.orange),
                tooltip: 'Recycle Bin (Data Dihapus)',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const TypeChassisRecycleBin(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Form Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _chassisController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Nama Type Chassis Baru',
                          hintText: 'Contoh: FM 260 JD',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama type chassis tidak boleh kosong';
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
                          vertical: 16,
                          horizontal: 24,
                        ),
                      ),
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(child: TypeChassisTable()),
        ],
      ),
    );
  }
}
