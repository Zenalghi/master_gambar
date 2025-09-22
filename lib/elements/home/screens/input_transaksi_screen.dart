// File: lib/elements/home/screens/input_transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/option_item.dart';
import '../providers/transaksi_providers.dart';
import '../repository/options_repository.dart';

class InputTransaksiScreen extends ConsumerWidget {
  const InputTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Daftarkan provider untuk TransaksiRepository jika belum ada
    final transaksiRepositoryProvider = Provider(
      (ref) => TransaksiRepository(ref),
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- AWAL PERUBAHAN LAYOUT ---

                      // Baris 1: Customer & Type Engine
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              context,
                              ref,
                              label: 'Customer',
                              optionsProvider: customerOptionsProvider,
                              selectedValueProvider: selectedCustomerProvider,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: _buildDropdown(
                              context,
                              ref,
                              label: 'Type Engine',
                              optionsProvider: typeEngineOptionsProvider,
                              selectedValueProvider: selectedTypeEngineProvider,
                              onChanged: (value) {
                                ref.read(selectedMerkProvider.notifier).state =
                                    null;
                                ref
                                        .read(
                                          selectedTypeChassisProvider.notifier,
                                        )
                                        .state =
                                    null;
                                ref
                                        .read(
                                          selectedJenisKendaraanProvider
                                              .notifier,
                                        )
                                        .state =
                                    null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // Baris 2: Merk & Type Chassis
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              context,
                              ref,
                              label: 'Merk',
                              optionsProvider: merkOptionsProvider,
                              selectedValueProvider: selectedMerkProvider,
                              onChanged: (value) {
                                ref
                                        .read(
                                          selectedTypeChassisProvider.notifier,
                                        )
                                        .state =
                                    null;
                                ref
                                        .read(
                                          selectedJenisKendaraanProvider
                                              .notifier,
                                        )
                                        .state =
                                    null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: _buildDropdown(
                              context,
                              ref,
                              label: 'Type Chassis',
                              optionsProvider: typeChassisOptionsProvider,
                              selectedValueProvider:
                                  selectedTypeChassisProvider,
                              onChanged: (value) {
                                ref
                                        .read(
                                          selectedJenisKendaraanProvider
                                              .notifier,
                                        )
                                        .state =
                                    null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // Baris 3: Jenis Kendaraan & Jenis Pengajuan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              context,
                              ref,
                              label: 'Jenis Kendaraan',
                              optionsProvider: jenisKendaraanOptionsProvider,
                              selectedValueProvider:
                                  selectedJenisKendaraanProvider,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: _buildDropdown(
                              context,
                              ref,
                              label: 'Jenis Pengajuan',
                              optionsProvider: jenisPengajuanOptionsProvider,
                              selectedValueProvider:
                                  selectedJenisPengajuanProvider,
                            ),
                          ),
                        ],
                      ),

                      // --- AKHIR PERUBAHAN LAYOUT ---
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final customerId = ref.read(selectedCustomerProvider);
                          final jenisKendaraanId = ref.read(
                            selectedJenisKendaraanProvider,
                          );
                          final jenisPengajuanId = ref.read(
                            selectedJenisPengajuanProvider,
                          );

                          if (customerId == null ||
                              jenisKendaraanId == null ||
                              jenisPengajuanId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harap lengkapi semua pilihan'),
                              ),
                            );
                            return;
                          }

                          ref
                              .read(transaksiRepositoryProvider)
                              .addTransaksi(
                                customerId: customerId,
                                jenisKendaraanId: jenisKendaraanId,
                                jenisPengajuanId: jenisPengajuanId,
                              );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaksi berhasil ditambahkan!'),
                            ),
                          );
                        },
                        child: const Text('Tambah Transaksi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ... (tabel di sini)
          ],
        ),
      ),
    );
  }

  // Helper widget (tidak ada perubahan di sini)
  Widget _buildDropdown(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required FutureProvider<List<OptionItem>> optionsProvider,
    required StateProvider selectedValueProvider,
    Function(dynamic)? onChanged,
  }) {
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
