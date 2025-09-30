import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';

class PilihVarianBodyCard extends ConsumerWidget {
  const PilihVarianBodyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton semua provider yang dibutuhkan
    final typeEngineOptions = ref.watch(typeEngineListProvider);
    final selectedTypeEngineId = ref.watch(mguSelectedTypeEngineIdProvider);

    final merkOptions = ref.watch(
      merkOptionsFamilyProvider(selectedTypeEngineId),
    );
    final selectedMerkId = ref.watch(mguSelectedMerkIdProvider);

    final typeChassisOptions = ref.watch(
      typeChassisOptionsFamilyProvider(selectedMerkId),
    );
    final selectedTypeChassisId = ref.watch(mguSelectedTypeChassisIdProvider);

    final jenisKendaraanOptions = ref.watch(
      jenisKendaraanOptionsFamilyProvider(selectedTypeChassisId),
    );
    final selectedJenisKendaraanId = ref.watch(
      mguSelectedJenisKendaraanIdProvider,
    );

    final varianBodyOptions = ref.watch(
      varianBodyOptionsFamilyProvider(selectedJenisKendaraanId),
    );
    final selectedVarianBodyId = ref.watch(mguSelectedVarianBodyIdProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Pilih Varian Body',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Type Engine
            typeEngineOptions.when(
              data: (options) => _buildDropdown<String>(
                label: 'Type Engine',
                value: selectedTypeEngineId,
                items: options
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.id,
                        child: Text(opt.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  ref.read(mguSelectedTypeEngineIdProvider.notifier).state =
                      value;
                  ref.read(mguSelectedMerkIdProvider.notifier).state = null;
                  ref.read(mguSelectedTypeChassisIdProvider.notifier).state =
                      null;
                  ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state =
                      null;
                  ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                      null;
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('Error'),
            ),
            const SizedBox(height: 16),

            // Merk
            merkOptions.when(
              data: (options) => _buildDropdown<String>(
                label: 'Merk',
                value: selectedMerkId,
                items: options
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.id as String,
                        child: Text(opt.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  ref.read(mguSelectedMerkIdProvider.notifier).state = value;
                  ref.read(mguSelectedTypeChassisIdProvider.notifier).state =
                      null;
                  ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state =
                      null;
                  ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                      null;
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('Error'),
            ),
            const SizedBox(height: 16),

            // Type Chassis
            typeChassisOptions.when(
              data: (options) => _buildDropdown<String>(
                label: 'Type Chassis',
                value: selectedTypeChassisId,
                items: options
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.id as String,
                        child: Text(opt.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  ref.read(mguSelectedTypeChassisIdProvider.notifier).state =
                      value;
                  ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state =
                      null;
                  ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                      null;
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('Error'),
            ),
            const SizedBox(height: 16),

            // Jenis Kendaraan
            jenisKendaraanOptions.when(
              data: (options) => _buildDropdown<String>(
                label: 'Jenis Kendaraan',
                value: selectedJenisKendaraanId,
                items: options
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.id as String,
                        child: Text(opt.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state =
                      value;
                  ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                      null;
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('Error'),
            ),
            const SizedBox(height: 16),

            // Varian Body
            varianBodyOptions.when(
              data: (options) => _buildDropdown<int>(
                label: 'Varian Body',
                value: selectedVarianBodyId,
                items: options
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt.id as int,
                        child: Text(opt.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    ref.read(mguSelectedVarianBodyIdProvider.notifier).state =
                        value,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('Error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
    );
  }
}
