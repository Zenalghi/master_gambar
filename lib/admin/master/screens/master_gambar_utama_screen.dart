// File: lib/admin/master/screens/master_gambar_utama_screen.dart

// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../widgets/pilih_file_pdf_card.dart';
import '../widgets/pilih_varian_body_card.dart';
import '../widgets/dependent_optional_form_card.dart'; // Pastikan ini di-import

class MasterGambarUtamaScreen extends ConsumerStatefulWidget {
  const MasterGambarUtamaScreen({super.key});
  @override
  ConsumerState<MasterGambarUtamaScreen> createState() =>
      _MasterGambarUtamaScreenState();
}

class _MasterGambarUtamaScreenState
    extends ConsumerState<MasterGambarUtamaScreen> {
  bool _isLoading = false;
  final _deskripsiController = TextEditingController();

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  void _resetForm() {
    // Reset semua state
    ref.read(mguSelectedMasterDataIdProvider.notifier).state =
        null; // Reset Master Data
    ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyNameProvider.notifier).state = null;

    ref.read(mguGambarUtamaFileProvider.notifier).state = null;
    ref.read(mguGambarTeruraiFileProvider.notifier).state = null;
    ref.read(mguGambarKontruksiFileProvider.notifier).state = null;

    ref.read(mguShowDependentOptionalProvider.notifier).state = false;
    ref.read(mguDependentFileProvider.notifier).state = null;
    _deskripsiController.clear();
  }

  void _resetAndRefresh() {
    _resetForm();
    ref.read(refreshNotifierProvider.notifier).refresh();
  }

  Future<void> _submit() async {
    final selectedMasterDataId = ref.read(mguSelectedMasterDataIdProvider);
    final selectedVarianBodyName = ref.read(mguSelectedVarianBodyNameProvider);

    final gambarUtamaFile = ref.read(mguGambarUtamaFileProvider);
    final gambarTeruraiFile = ref.read(mguGambarTeruraiFileProvider);
    final gambarKontruksiFile = ref.read(mguGambarKontruksiFileProvider);

    final showDependent = ref.read(mguShowDependentOptionalProvider);
    final dependentFile = ref.read(mguDependentFileProvider);

    // Validasi dasar
    if (selectedMasterDataId == null ||
        selectedVarianBodyName == null ||
        gambarUtamaFile == null ||
        gambarTeruraiFile == null ||
        gambarKontruksiFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap lengkapi Master Data, Varian Body, dan 3 file PDF.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validasi dependen
    if (showDependent &&
        (_deskripsiController.text.isEmpty || dependentFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap isi deskripsi dan pilih file untuk Gambar Optional Paket.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // --- LANGKAH 1: UPLOAD GAMBAR UTAMA ---
      // Kita gunakan method yang mengembalikan objek GGambarUtama agar dapat ID-nya
      final gambarUtama = await ref
          .read(masterDataRepositoryProvider)
          .uploadGambarUtamaWithResult(
            masterDataId: selectedMasterDataId,
            varianBodyName: selectedVarianBodyName,
            gambarUtama: gambarUtamaFile,
            gambarTerurai: gambarTeruraiFile,
            gambarKontruksi: gambarKontruksiFile,
          );

      // --- LANGKAH 2: UPLOAD GAMBAR OPTIONAL PAKET (JIKA ADA) ---
      if (showDependent) {
        await ref
            .read(masterDataRepositoryProvider)
            .addGambarOptional(
              deskripsi: _deskripsiController.text,
              gambarOptionalFile: dependentFile!,
              tipe: 'paket',
              gambarUtamaId: gambarUtama.id,
              // Tidak perlu varianBodyId untuk paket
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar Utama & Paket berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );
      _resetForm();
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.response?.data['message'] ?? e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showDependent = ref.watch(mguShowDependentOptionalProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Manajemen Gambar Utama',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: _resetAndRefresh,
              ),
            ],
          ),
          const SizedBox(height: 16),

          const PilihVarianBodyCard(), // Widget ini sekarang berisi 2 dropdown baru

          const Divider(height: 32),

          CheckboxListTile(
            title: const Text("Tambahkan Gambar Optional Paket"),
            value: showDependent,
            onChanged: (value) =>
                ref.read(mguShowDependentOptionalProvider.notifier).state =
                    value!,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),

          if (showDependent)
            DependentOptionalFormCard(
              deskripsiController: _deskripsiController,
            ),

          const Divider(height: 32),

          PilihFilePdfCard(onSubmit: _submit, isLoading: _isLoading),
        ],
      ),
    );
  }
}
