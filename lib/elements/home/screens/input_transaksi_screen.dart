import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/option_item.dart';
import '../providers/transaksi_providers.dart';
import '../widgets/transaksi_history_table.dart';

class InputTransaksiScreen extends ConsumerWidget {
  const InputTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      // 1. Ganti SingleChildScrollView menjadi Padding biasa
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // 2. Gunakan Column sebagai widget utama di body
        child: Column(
          children: [
            // Widget Card untuk form tidak berubah
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ... (semua widget Row dan dropdown Anda tidak berubah)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              context, ref,
                              label: 'Customer',
                              optionsProvider: customerOptionsProvider,
                              selectedValueProvider: selectedCustomerProvider,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: _buildDropdown(
                              context, ref,
                              label: 'Type Engine',
                              optionsProvider: typeEngineOptionsProvider,
                              selectedValueProvider: selectedTypeEngineProvider,
                              onChanged: (value) {
                                ref.read(selectedMerkProvider.notifier).state = null;
                                ref.read(selectedTypeChassisProvider.notifier).state = null;
                                ref.read(selectedJenisKendaraanProvider.notifier).state = null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              context, ref,
                              label: 'Merk',
                              optionsProvider: merkOptionsProvider,
                              selectedValueProvider: selectedMerkProvider,
                              onChanged: (value) {
                                ref.read(selectedTypeChassisProvider.notifier).state = null;
                                ref.read(selectedJenisKendaraanProvider.notifier).state = null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: _buildDropdown(
                              context, ref,
                              label: 'Type Chassis',
                              optionsProvider: typeChassisOptionsProvider,
                              selectedValueProvider: selectedTypeChassisProvider,
                              onChanged: (value) {
                                ref.read(selectedJenisKendaraanProvider.notifier).state = null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              context, ref,
                              label: 'Jenis Kendaraan',
                              optionsProvider: jenisKendaraanOptionsProvider,
                              selectedValueProvider: selectedJenisKendaraanProvider,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: _buildDropdown(
                              context, ref,
                              label: 'Jenis Pengajuan',
                              optionsProvider: jenisPengajuanOptionsProvider,
                              selectedValueProvider: selectedJenisPengajuanProvider,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          // ... (logika onPressed Anda tidak berubah)
                        },
                        child: const Text('Tambah Transaksi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 3. Bungkus Card tabel dengan widget Expanded
            Expanded(
              child: Card(
                child: SizedBox(
                  width: double.infinity,
                  child: TransaksiHistoryTable(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget _buildDropdown (tidak berubah)
  Widget _buildDropdown(
      BuildContext context,
      WidgetRef ref, {
      required String label,
      required FutureProvider<List<OptionItem>> optionsProvider,
      required StateProvider selectedValueProvider,
      Function(dynamic)? onChanged,
    }) {
      // ... (isi fungsi ini sama seperti sebelumnya)
      final options = ref.watch(optionsProvider);
    final selectedValue = ref.watch(selectedValueProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: options.when(
        data: (items) => DropdownButtonFormField<dynamic>(
          value: selectedValue,
          items: items.map((item) {
            return DropdownMenuItem<dynamic>(
              value: item.id,
              child: Text(item.name),
            );
          }).toList(),
          onChanged: (value) {
            ref.read(selectedValueProvider.notifier).state = value;
            if (onChanged != null) onChanged(value);
          },
          decoration: InputDecoration(labelText: label),
          isExpanded: true,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text('Gagal memuat $label'),
      ),
    );
  }
}