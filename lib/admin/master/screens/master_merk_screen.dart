import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../widgets/merk_table.dart';

class MasterMerkScreen extends ConsumerStatefulWidget {
  const MasterMerkScreen({super.key});
  @override
  ConsumerState<MasterMerkScreen> createState() => _MasterMerkScreenState();
}

class _MasterMerkScreenState extends ConsumerState<MasterMerkScreen> {
  final _merkController = TextEditingController();
  String? _selectedTypeEngineId;

  @override
  void dispose() {
    _merkController.dispose();
    super.dispose();
  }

  void _resetAndRefresh() {
    setState(() {
      _selectedTypeEngineId = null;
      _merkController.clear();
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
    if (_selectedTypeEngineId == null || _merkController.text.isEmpty) {
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
          .addMerk(
            typeEngineId: _selectedTypeEngineId!,
            merk: _merkController.text,
          );
      _merkController.clear();
      ref.invalidate(merkListProvider);
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Merk',
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
                  onChanged: (value) =>
                      ref.read(merkSearchQueryProvider.notifier).state = value,
                ),
              ),

              // ------------------------------------
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: () {
                  _resetAndRefresh();
                  ref.invalidate(merkListProvider);
                  ref.invalidate(typeEngineListProvider);
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
                          labelText: 'Pilih Type Engine (Induk)',
                        ),
                        items: options
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt.id,
                                child: Text(opt.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedTypeEngineId = value),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => const Text('Error memuat Type Engine'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _merkController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Nama Merk Baru',
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
          const Expanded(child: MerkTable()),
        ],
      ),
    );
  }
}
