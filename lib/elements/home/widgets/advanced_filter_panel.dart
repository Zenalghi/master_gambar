// File: lib/elements/home/widgets/advanced_filter_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/option_item.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';

class AdvancedFilterPanel extends ConsumerWidget {
  const AdvancedFilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      title: const Text('Filter Lanjutan'),
      maintainState: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: [
                  _buildFilterDropdown(
                    ref,
                    'customer_id',
                    'Filter Customer',
                    customerOptionsProvider,
                  ),
                  _buildFilterDropdown(
                    ref,
                    'a_type_engine_id',
                    'Filter Type Engine',
                    typeEngineOptionsProvider,
                  ),
                  _buildFilterDropdown(
                    ref,
                    'f_pengajuan_id',
                    'Filter Jenis Pengajuan',
                    jenisPengajuanOptionsProvider,
                  ),
                  // Anda bisa menambahkan dropdown lain di sini jika perlu (Merk, Chassis, dll.)
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Invalidate akan mereset provider ke state awalnya
                    ref.invalidate(transaksiFilterProvider);
                  },
                  child: const Text('Bersihkan Filter'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    WidgetRef ref,
    String filterKey,
    String label,
    FutureProvider<List<OptionItem>> optionsProvider,
  ) {
    final options = ref.watch(optionsProvider);
    final currentFilters = ref.watch(transaksiFilterProvider);

    return SizedBox(
      width: 250,
      child: options.when(
        data: (items) => DropdownButtonFormField<dynamic>(
          value: currentFilters[filterKey],
          decoration: InputDecoration(labelText: label, isDense: true),
          items: items
              .map(
                (item) => DropdownMenuItem<dynamic>(
                  value: item.id,
                  child: Text(item.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            ref.read(transaksiFilterProvider.notifier).update((state) {
              return {...state, filterKey: value};
            });
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Text('Error memuat $label'),
      ),
    );
  }
}
