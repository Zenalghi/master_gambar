import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../widgets/type_chassis_table.dart';

class MasterTypeChassisScreen extends ConsumerStatefulWidget {
  const MasterTypeChassisScreen({super.key});
  @override
  ConsumerState<MasterTypeChassisScreen> createState() =>
      _MasterTypeChassisScreenState();
}

class _MasterTypeChassisScreenState
    extends ConsumerState<MasterTypeChassisScreen> {
  final _chassisController = TextEditingController();
  String? _selectedTypeEngineId;
  String? _selectedMerkId;

  @override
  void dispose() {
    _chassisController.dispose();
    super.dispose();
  }

  void _resetAndRefresh() {
    setState(() {
      _selectedTypeEngineId = null;
      _selectedMerkId = null;
      _chassisController.clear();
    });
    ref.invalidate(typeEngineListProvider);
    ref.invalidate(merkOptionsFamilyProvider);
    ref.invalidate(typeChassisOptionsFamilyProvider);
    ref.invalidate(jenisKendaraanOptionsFamilyProvider);
    ref.invalidate(varianBodyOptionsFamilyProvider);
    ref.invalidate(gambarOptionalListProvider);
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  void _submit() async {
    if (_selectedMerkId == null || _chassisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua field.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .addTypeChassis(
            merkId: _selectedMerkId!,
            typeChassis: _chassisController.text,
          );
      _chassisController.clear();
      ref
          .read(typeChassisFilterProvider.notifier)
          .update((state) => Map.from(state));
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.response?.data['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeEngineOptions = ref.watch(typeEngineListProvider);
    final merkOptions = ref.watch(
      merkOptionsFamilyProvider(_selectedTypeEngineId),
    );

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

              // --- TAMBAHKAN KOLOM SEARCH DI SINI ---
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(typeChassisFilterProvider.notifier)
                        .update((state) => {...state, 'search': value});
                  },
                ),
              ),

              // ------------------------------------
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  ref
                      .read(typeChassisFilterProvider.notifier)
                      .update((state) => Map.from(state));
                  ref.invalidate(typeEngineListProvider);
                  _resetAndRefresh();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: typeEngineOptions.when(
                      data: (options) => DropdownButtonFormField<String>(
                        value: _selectedTypeEngineId,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Type Engine',
                        ),
                        items: options
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt.id,
                                child: Text(opt.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() {
                          _selectedTypeEngineId = value;
                          _selectedMerkId = null;
                        }),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => const Text('Error'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: merkOptions.when(
                      data: (options) => DropdownButtonFormField<String>(
                        value: _selectedMerkId,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Merk',
                        ),
                        items: options
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt.id as String,
                                child: Text(opt.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedMerkId = value),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => const Text('Error'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _chassisController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Nama Type Chassis Baru',
                      ),
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
          const SizedBox(height: 16),
          const Expanded(child: TypeChassisTable()),
        ],
      ),
    );
  }
}
