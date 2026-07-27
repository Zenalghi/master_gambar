import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';

class ImageStatusAdvancedFilterPanel extends ConsumerStatefulWidget {
  const ImageStatusAdvancedFilterPanel({super.key});

  @override
  ConsumerState<ImageStatusAdvancedFilterPanel> createState() =>
      _ImageStatusAdvancedFilterPanelState();
}

class _ImageStatusAdvancedFilterPanelState
    extends ConsumerState<ImageStatusAdvancedFilterPanel> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(imageStatusFilterProvider);
    _controllers = {
      'id': TextEditingController(text: currentFilters['id'] ?? ''),
      'type_engine': TextEditingController(
        text: currentFilters['type_engine'] ?? '',
      ),
      'merk': TextEditingController(text: currentFilters['merk'] ?? ''),
      'type_chassis': TextEditingController(
        text: currentFilters['type_chassis'] ?? '',
      ),
      'jenis_kendaraan': TextEditingController(
        text: currentFilters['jenis_kendaraan'] ?? '',
      ),
      'varian_body': TextEditingController(
        text: currentFilters['varian_body'] ?? '',
      ),
      'created_at': TextEditingController(
        text: currentFilters['created_at'] ?? '',
      ),
      'updated_at': TextEditingController(
        text: currentFilters['updated_at'] ?? '',
      ),
      'deskripsi_optional': TextEditingController(
        text: currentFilters['deskripsi_optional'] ?? '',
      ),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _applyFilters() {
    final Map<String, String?> newFilters = {};
    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        newFilters[key] = controller.text;
      } else {
        newFilters[key] = null;
      }
    });

    ref
        .read(imageStatusFilterProvider.notifier)
        .update((state) => {...state, ...newFilters});
  }

  void _clearFilters() {
    _controllers.forEach((_, controller) => controller.clear());
    ref.invalidate(imageStatusFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      minTileHeight: 1,
      title: const Text("Filter Lanjutan", style: TextStyle(fontSize: 14)),
      maintainState: true,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Pengaman: Jika layar di bawah 900px, tetapkan minimal lebar 900px agar Expanded tidak error/overflow.
            // Di atas 900px, akan mengikuti lebar layar (maxWidth) secara proporsional.
            double rowWidth = constraints.maxWidth < 900
                ? 900
                : constraints.maxWidth;

            return Column(
              children: [
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: rowWidth,
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        // 1. Widget Custom (SizedBox) - Lebar Tetap & Prediktif
                        _tfCustom("ID", _controllers['id']!, 62),
                        const SizedBox(width: 6),
                        _tfCustom(
                          "Type Engine",
                          _controllers['type_engine']!,
                          90,
                        ),
                        const SizedBox(width: 6),
                        _tfCustom("Merk", _controllers['merk']!, 127),
                        const SizedBox(width: 6),

                        // 2. Widget Expanded - Mengisi Sisa Ruang Proporsional
                        _tfExpanded(
                          "Type Chassis",
                          _controllers['type_chassis']!,
                          flex: 2,
                        ),
                        const SizedBox(width: 6),
                        _tfExpanded(
                          "Jenis Kendaraan",
                          _controllers['jenis_kendaraan']!,
                          flex: 2,
                        ),
                        const SizedBox(width: 6),
                        _tfExpanded(
                          "Varian Body",
                          _controllers['varian_body']!,
                          flex: 2,
                        ),
                        const SizedBox(width: 6),

                        // 3. Widget Custom (SizedBox) - Untuk Format Tanggal
                        _tfCustom(
                          "Created At",
                          _controllers['created_at']!,
                          139,
                        ),
                        const SizedBox(width: 6),
                        _tfCustom(
                          "Updated At",
                          _controllers['updated_at']!,
                          139,
                        ),
                        const SizedBox(width: 6),

                        // 4. Widget Expanded - Untuk Deskripsi Optional Paket
                        _tfExpanded(
                          "Gbr. Optional Paket",
                          _controllers['deskripsi_optional']!,
                          flex: 2,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text(
                        "Bersihkan",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text(
                        "Terapkan Filter",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  // 1. WIDGET CUSTOM LEBAR TETAP (Menggunakan SizedBox)
  Widget _tfCustom(
    String label,
    TextEditingController controller,
    double width,
  ) {
    return SizedBox(
      width: width,
      height: 35,
      child: TextField(
        style: const TextStyle(fontSize: 11),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11, height: 3.0),
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _applyFilters(),
      ),
    );
  }

  // 2. WIDGET EXPANDED (Menggunakan Expanded)
  Widget _tfExpanded(
    String label,
    TextEditingController controller, {
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: SizedBox(
        height: 35,
        child: TextField(
          style: const TextStyle(fontSize: 11),
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 11, height: 3.0),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _applyFilters(),
        ),
      ),
    );
  }
}
