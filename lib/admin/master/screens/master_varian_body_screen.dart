import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../widgets/varian_body_table.dart';

class MasterVarianBodyScreen extends ConsumerStatefulWidget {
  const MasterVarianBodyScreen({super.key});
  @override
  ConsumerState<MasterVarianBodyScreen> createState() =>
      _MasterVarianBodyScreenState();
}

class _MasterVarianBodyScreenState
    extends ConsumerState<MasterVarianBodyScreen> {
  final _varianBodyController = TextEditingController();
  String? _selectedTypeEngineId;
  String? _selectedMerkId;
  String? _selectedTypeChassisId;
  String? _selectedJenisKendaraanId;

  @override
  void dispose() {
    _varianBodyController.dispose();
    super.dispose();
  }

  void _resetAndRefresh() {
    setState(() {
      _selectedTypeEngineId = null;
      _selectedMerkId = null;
      _selectedTypeChassisId = null;
      _selectedJenisKendaraanId = null;
      _varianBodyController.clear();
    });
    ref.invalidate(merkOptionsFamilyProvider);
    ref.invalidate(typeChassisOptionsFamilyProvider);
    ref.invalidate(jenisKendaraanOptionsFamilyProvider);
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  void _submit() async {
    if (_selectedJenisKendaraanId == null ||
        _varianBodyController.text.isEmpty) {
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
          .addVarianBody(
            jenisKendaraanId: _selectedJenisKendaraanId!,
            varianBody: _varianBodyController.text,
          );
      _varianBodyController.clear();
      ref
          .read(varianBodyFilterProvider.notifier)
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
    // Watch all providers needed for the dropdowns
    final typeEngineOptions = ref.watch(typeEngineListProvider);
    final merkOptions = ref.watch(
      merkOptionsFamilyProvider(_selectedTypeEngineId),
    );
    final typeChassisOptions = ref.watch(
      typeChassisOptionsFamilyProvider(_selectedMerkId),
    );
    final jenisKendaraanOptions = ref.watch(
      jenisKendaraanOptionsFamilyProvider(_selectedTypeChassisId),
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Varian Body',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
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
                        .read(varianBodyFilterProvider.notifier)
                        .update((state) => {...state, 'search': value});
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  _resetAndRefresh();
                  ref
                      .read(varianBodyFilterProvider.notifier)
                      .update((state) => Map.from(state));
                  ref.invalidate(typeEngineListProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
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
                              _selectedTypeChassisId = null;
                              _selectedJenisKendaraanId = null;
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
                            onChanged: (value) => setState(() {
                              _selectedMerkId = value;
                              _selectedTypeChassisId = null;
                              _selectedJenisKendaraanId = null;
                            }),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) => const Text('Error'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: typeChassisOptions.when(
                          data: (options) => DropdownButtonFormField<String>(
                            value: _selectedTypeChassisId,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Type Chassis',
                            ),
                            items: options
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt.id as String,
                                    child: Text(opt.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() {
                              _selectedTypeChassisId = value;
                              _selectedJenisKendaraanId = null;
                            }),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) => const Text('Error'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: jenisKendaraanOptions.when(
                          data: (options) => DropdownButtonFormField<String>(
                            value: _selectedJenisKendaraanId,
                            decoration: const InputDecoration(
                              labelText: 'Pilih Jenis Kendaraan',
                            ),
                            items: options
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt.id as String,
                                    child: Text(opt.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(
                              () => _selectedJenisKendaraanId = value,
                            ),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) => const Text('Error'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _varianBodyController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Nama Varian Body Baru',
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(child: VarianBodyTable()),
        ],
      ),
    );
  }
}
