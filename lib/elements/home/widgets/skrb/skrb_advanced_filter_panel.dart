// File: lib/elements/home/widgets/skrb/skrb_advanced_filter_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/skrb_providers.dart';

class SkrbAdvancedFilterPanel extends ConsumerStatefulWidget {
  const SkrbAdvancedFilterPanel({super.key});

  @override
  ConsumerState<SkrbAdvancedFilterPanel> createState() =>
      _SkrbAdvancedFilterPanelState();
}

class _SkrbAdvancedFilterPanelState
    extends ConsumerState<SkrbAdvancedFilterPanel> {
  late final Map<String, TextEditingController> _controllers;
  String _selectedStatusTdp = '';

  @override
  void initState() {
    super.initState();
    _controllers = {
      'id_skrb': TextEditingController(),
      'id_dwg': TextEditingController(),
      'customer_name': TextEditingController(),
      'type_engine': TextEditingController(),
      'merk': TextEditingController(),
      'type_chassis': TextEditingController(),
      'jenis_kendaraan': TextEditingController(),
      'jenis_pengajuan': TextEditingController(),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _applyFilters() {
    final Map<String, String> newFilters = {};
    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        newFilters[key] = controller.text.trim();
      }
    });
    if (_selectedStatusTdp.isNotEmpty) {
      newFilters['status_tdp'] = _selectedStatusTdp;
    }

    ref.read(skrbFilterProvider.notifier).state = newFilters;
  }

  void _clearFilters() {
    _controllers.forEach((_, controller) => controller.clear());
    setState(() => _selectedStatusTdp = '');
    ref.read(skrbFilterProvider.notifier).state = {};
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      minTileHeight: 1,
      title: const Text("Filter Lanjutan", style: TextStyle(fontSize: 14)),
      maintainState: true,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            // Responsif untuk layar monitor 1360x768 (dengan 9 field)
            double itemWidth = (maxWidth / 9.5).clamp(115, 230);

            return Column(
              children: [
                const SizedBox(height: 2),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 8,
                  children: [
                    _tf("ID SKRB", _controllers['id_skrb']!, itemWidth),
                    _tf("ID DWG", _controllers['id_dwg']!, itemWidth),
                    _tf("Customer", _controllers['customer_name']!, itemWidth),
                    _tf("Type Engine", _controllers['type_engine']!, itemWidth),
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
                    _buildDropdownStatus(itemWidth),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text(
                        "Bersihkan",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text(
                        "Terapkan Filter",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
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
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 3),
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

  Widget _buildDropdownStatus(double width) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 11,
        ) ??
        const TextStyle(fontSize: 11);

    return Container(
      width: width,
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedStatusTdp,
        decoration: const InputDecoration(
          labelText: 'Status TDP',
          labelStyle: TextStyle(fontSize: 11, height: 3.0),
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        style: textStyle,
        items: [
          DropdownMenuItem(value: '', child: Text('Semua Status', style: textStyle)),
          DropdownMenuItem(value: 'aktif', child: Text('Aktif', style: textStyle)),
          DropdownMenuItem(
            value: 'warning',
            child: Text('Warning', style: textStyle),
          ),
          DropdownMenuItem(
            value: 'expired',
            child: Text('Expired', style: textStyle),
          ),
          DropdownMenuItem(
            value: 'diperbarui admin',
            child: Text('Diperbarui Admin', style: textStyle),
          ),
        ],
        onChanged: (val) {
          setState(() => _selectedStatusTdp = val ?? '');
          _applyFilters();
        },
      ),
    );
  }
}
