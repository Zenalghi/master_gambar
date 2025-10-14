import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';

class AdvancedFilterPanel extends ConsumerStatefulWidget {
  const AdvancedFilterPanel({super.key});

  @override
  ConsumerState<AdvancedFilterPanel> createState() =>
      _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends ConsumerState<AdvancedFilterPanel> {
  // Buat TextEditingController untuk setiap field
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    // Inisialisasi semua controller
    _controllers = {
      'customer': TextEditingController(),
      'type_engine': TextEditingController(),
      'merk': TextEditingController(),
      'type_chassis': TextEditingController(),
      'jenis_kendaraan': TextEditingController(),
      'jenis_pengajuan': TextEditingController(),
      'user': TextEditingController(),
    };
  }

  @override
  void dispose() {
    // Jangan lupa dispose semua controller
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _applyFilters() {
    // Buat map baru untuk menampung filter yang diisi
    final Map<String, String?> newFilters = {};
    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        newFilters[key] = controller.text;
      }
    });

    // Update provider utama dengan semua filter baru
    ref.read(transaksiFilterProvider.notifier).update((state) {
      // Gabungkan state lama (untuk sort) dengan filter baru
      return {...state, ...newFilters};
    });
  }

  void _clearFilters() {
    // Kosongkan semua text field
    _controllers.forEach((_, controller) => controller.clear());
    // Invalidate provider untuk meresetnya ke state awal
    ref.invalidate(transaksiFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filter Lanjutan'),
      maintainState: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Wrap(
                // spacing: 16.0,
                runSpacing: 16.0,
                children: [
                  _buildFilterTextField(
                    label: 'Filter Customer',
                    controller: _controllers['customer']!,
                  ),
                  _buildFilterTextField(
                    label: 'Filter Type Engine',
                    controller: _controllers['type_engine']!,
                  ),
                  _buildFilterTextField(
                    label: 'Filter Merk',
                    controller: _controllers['merk']!,
                  ),
                  _buildFilterTextField(
                    label: 'Filter Type Chassis',
                    controller: _controllers['type_chassis']!,
                  ),
                  _buildFilterTextField(
                    label: 'Filter Jenis Kendaraan',
                    controller: _controllers['jenis_kendaraan']!,
                  ),
                  _buildFilterTextField(
                    label: 'Filter Jenis Pengajuan',
                    controller: _controllers['jenis_pengajuan']!,
                  ),
                  _buildFilterTextField(
                    label: 'Filter User',
                    controller: _controllers['user']!,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    ),
                    icon: const Icon(Icons.clear),
                    label: const Text('Bersihkan'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.search),
                    label: const Text('Terapkan Filter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, isDense: true),
        onSubmitted: (_) =>
            _applyFilters(), // Terapkan filter saat menekan Enter
      ),
    );
  }
}
