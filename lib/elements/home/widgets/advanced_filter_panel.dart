// File: lib/elements/home/widgets/advanced_filter_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers/transaksi_providers.dart';

class AdvancedFilterPanel extends ConsumerWidget {
  const AdvancedFilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      title: const Text('Filter Lanjutan'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            // Wrap agar responsif
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              _buildFilterTextField(
                ref,
                label: 'Filter Customer',
                provider: customerFilterProvider,
              ),
              _buildFilterTextField(
                ref,
                label: 'Filter Type Engine',
                provider: typeEngineFilterProvider,
              ),
              //merk
              _buildFilterTextField(
                ref,
                label: 'Filter Merk',
                provider: merkFilterProvider,
              ),
              //type chassis
              _buildFilterTextField(
                ref,
                label: 'Filter Type Chassis',
                provider: typeChassisFilterProvider,
              ),
              //jenis kendaraan
              _buildFilterTextField(
                ref,
                label: 'Filter Jenis Kendaraan',
                provider: jenisKendaraanFilterProvider,
              ),
              _buildFilterTextField(
                ref,
                label: 'Filter Jenis Pengajuan',
                provider: jenisPengajuanFilterProvider,
              ),
              _buildFilterTextField(
                ref,
                label: 'Filter User',
                provider: userFilterProvider,
              ),
              // Tambahkan TextField lain di sini sesuai kebutuhan
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTextField(
    WidgetRef ref, {
    required String label,
    required StateProvider<String> provider,
  }) {
    return SizedBox(
      width: 200,
      child: TextField(
        decoration: InputDecoration(labelText: label, isDense: true),
        onChanged: (value) => ref.read(provider.notifier).state = value,
      ),
    );
  }
}
