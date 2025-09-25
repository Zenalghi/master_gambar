// File: lib/elements/home/widgets/advanced_filter_panel.dart
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers/transaksi_providers.dart';

class AdvancedFilterPanel extends ConsumerStatefulWidget {
  const AdvancedFilterPanel({super.key});

  @override
  ConsumerState<AdvancedFilterPanel> createState() =>
      _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends ConsumerState<AdvancedFilterPanel> {
  // LANGKAH 3: Buat TextEditingController untuk setiap field
  late final TextEditingController _customerController;
  late final TextEditingController _typeEngineController;
  late final TextEditingController _merkController;
  late final TextEditingController _typeChassisController;
  late final TextEditingController _jenisKendaraanController;
  late final TextEditingController _jenisPengajuanController;
  late final TextEditingController _userController;

  @override
  void initState() {
    super.initState();
    // LANGKAH 4: Inisialisasi controller dan tambahkan listener
    // Listener akan mengupdate provider Riverpod setiap kali teks diubah
    _customerController = TextEditingController();
    _customerController.addListener(() {
      ref.read(customerFilterProvider.notifier).state =
          _customerController.text;
    });

    _typeEngineController = TextEditingController();
    _typeEngineController.addListener(() {
      ref.read(typeEngineFilterProvider.notifier).state =
          _typeEngineController.text;
    });

    _merkController = TextEditingController();
    _merkController.addListener(() {
      ref.read(merkFilterProvider.notifier).state = _merkController.text;
    });

    _typeChassisController = TextEditingController();
    _typeChassisController.addListener(() {
      ref.read(typeChassisFilterProvider.notifier).state =
          _typeChassisController.text;
    });

    _jenisKendaraanController = TextEditingController();
    _jenisKendaraanController.addListener(() {
      ref.read(jenisKendaraanFilterProvider.notifier).state =
          _jenisKendaraanController.text;
    });

    _jenisPengajuanController = TextEditingController();
    _jenisPengajuanController.addListener(() {
      ref.read(jenisPengajuanFilterProvider.notifier).state =
          _jenisPengajuanController.text;
    });

    _userController = TextEditingController();
    _userController.addListener(() {
      ref.read(userFilterProvider.notifier).state = _userController.text;
    });
  }

  @override
  void dispose() {
    // LANGKAH 6: Jangan lupa dispose semua controller untuk mencegah memory leak
    _customerController.dispose();
    _typeEngineController.dispose();
    _merkController.dispose();
    _typeChassisController.dispose();
    _jenisKendaraanController.dispose();
    _jenisPengajuanController.dispose();
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filter Lanjutan'),
      // Jaga state agar tidak hancur saat di-minimize
      maintainState: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              // LANGKAH 5: Gunakan method build yang baru dengan controller
              _buildFilterTextField(
                label: 'Filter Customer',
                controller: _customerController,
              ),
              _buildFilterTextField(
                label: 'Filter Type Engine',
                controller: _typeEngineController,
              ),
              _buildFilterTextField(
                label: 'Filter Merk',
                controller: _merkController,
              ),
              _buildFilterTextField(
                label: 'Filter Type Chassis',
                controller: _typeChassisController,
              ),
              _buildFilterTextField(
                label: 'Filter Jenis Kendaraan',
                controller: _jenisKendaraanController,
              ),
              _buildFilterTextField(
                label: 'Filter Jenis Pengajuan',
                controller: _jenisPengajuanController,
              ),
              _buildFilterTextField(
                label: 'Filter User',
                controller: _userController,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Method helper ini sekarang menerima controller, bukan provider
  Widget _buildFilterTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return SizedBox(
      width: 200,
      child: TextField(
        // Hubungkan controller ke TextField
        controller: controller,
        decoration: InputDecoration(labelText: label, isDense: true),
        // onChanged tidak diperlukan lagi karena sudah dihandle oleh listener
      ),
    );
  }
}
