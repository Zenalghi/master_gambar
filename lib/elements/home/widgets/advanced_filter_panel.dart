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
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
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

  void _applyFilters() {
    final Map<String, String?> newFilters = {};
    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) newFilters[key] = controller.text;
    });

    ref
        .read(transaksiFilterProvider.notifier)
        .update((state) => {...state, ...newFilters});
  }

  void _clearFilters() {
    _controllers.forEach((_, controller) => controller.clear());
    ref.invalidate(transaksiFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text("Filter Lanjutan"),
      maintainState: true,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;

            // Ukuran textfield responsif, tapi tetap wajar
            double itemWidth = (maxWidth / 9).clamp(160, 300);

            return Column(
              children: [
                // SCROLL HORIZONTAL, ROW DI TENGAH
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 0,
                        maxWidth: maxWidth,
                      ),
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10),
                            _tf(
                              "Customer",
                              _controllers['customer']!,
                              itemWidth,
                            ),
                            _tf(
                              "Type Engine",
                              _controllers['type_engine']!,
                              itemWidth,
                            ),
                            _tf("Merk", _controllers['merk']!, itemWidth),
                            _tf(
                              "Type Chassis",
                              _controllers['type_chassis']!,
                              itemWidth,
                            ),
                            _tf(
                              "Jenis Kendaraan",
                              _controllers['jenis_kendaraan']!,
                              itemWidth,
                            ),
                            _tf(
                              "Jenis Pengajuan",
                              _controllers['jenis_pengajuan']!,
                              itemWidth,
                            ),
                            _tf("User", _controllers['user']!, itemWidth),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.clear),
                      label: const Text("Bersihkan"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.search),
                      label: const Text("Terapkan Filter"),
                    ),
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

  Widget _tf(String label, TextEditingController controller, double width) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _applyFilters(),
      ),
    );
  }
}
