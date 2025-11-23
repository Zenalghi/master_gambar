// File: lib/admin/master/screens/master_gambar_utama_screen.dart

import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:path_provider/path_provider.dart'; // Perlu tambah package ini di pubspec.yaml jika belum ada
import '../../../app/core/notifiers/refresh_notifier.dart';
import '../widgets/pilih_file_pdf_card.dart';
import '../widgets/pilih_varian_body_card.dart';
import '../widgets/dependent_optional_form_card.dart';

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

  @override
  Widget build(BuildContext context) {
    // DENGARKAN PROVIDER EDIT
    ref.listen<GGambarUtama?>(mguEditingGambarProvider, (prev, next) {
      if (next != null) {
        // Jika ada data edit masuk, jalankan proses loading data
        _loadExistingData(next);
      }
    });

    final showDependent = ref.watch(mguShowDependentOptionalProvider);
    // Cek apakah sedang mode edit untuk mengubah teks tombol/judul jika perlu
    final isEditing = ref.watch(mguEditingGambarProvider) != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isEditing ? 'Edit Gambar Utama' : 'Manajemen Gambar Utama',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset & Refresh',
                onPressed: _resetAndRefresh,
              ),
            ],
          ),

          // Tampilkan loading overlay jika sedang mengambil file dari server
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            const SizedBox(height: 16),
            const PilihVarianBodyCard(),
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
        ],
      ),
    );
  }

  // --- LOGIKA BARU UNTUK MEMUAT DATA EDIT ---
  Future<void> _loadExistingData(GGambarUtama gambarUtama) async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(masterDataRepositoryProvider);

      // 1. Ambil Path dari Server
      final paths = await repo.getGambarUtamaPaths(gambarUtama.id);

      // 2. Fungsi helper untuk download dan konversi ke File
      Future<File> downloadToTemp(String path, String filename) async {
        final bytes = await repo.getPdfFromPath(path);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(bytes);
        return file;
      }

      // 3. Download 3 Gambar Utama secara paralel
      final results = await Future.wait([
        downloadToTemp(paths['utama']!, 'utama_existing.pdf'),
        downloadToTemp(paths['terurai']!, 'terurai_existing.pdf'),
        downloadToTemp(paths['kontruksi']!, 'kontruksi_existing.pdf'),
      ]);

      // 4. Isi Provider File
      ref.read(mguGambarUtamaFileProvider.notifier).state = results[0];
      ref.read(mguGambarTeruraiFileProvider.notifier).state = results[1];
      ref.read(mguGambarKontruksiFileProvider.notifier).state = results[2];

      // 5. Handle Gambar Optional Paket (jika ada)
      // Kita cari yang tipe 'paket' dari list gambarOptionals di model
      final paketOptional = gambarUtama.gambarOptionals
          .where((g) => g.tipe == 'paket')
          .firstOrNull;

      if (paketOptional != null) {
        // Aktifkan checkbox
        ref.read(mguShowDependentOptionalProvider.notifier).state = true;
        // Isi deskripsi
        _deskripsiController.text = paketOptional.deskripsi;

        // Download file optional
        // Kita butuh pathnya. Karena model GambarOptional sudah punya path, kita bisa pakai itu.
        // Tapi hati-hati, path di model mungkin relative. Kita coba gunakan repo getPdfFromPath
        // dengan asumsi logic backend viewPdf bisa handle path yang ada di model.
        // Atau gunakan endpoint khusus jika ada.
        // SEMENTARA: Kita coba download menggunakan path dari model via viewPdf

        // NOTE: getPdfFromPath di repo menggunakan endpoint '/admin/master-gambar/view'
        // yang menerima parameter 'path'. Ini cocok.

        final optBytes = await repo.getPdfFromPath(paketOptional.path);
        final tempDir = await getTemporaryDirectory();
        final optFile = File('${tempDir.path}/optional_paket_existing.pdf');
        await optFile.writeAsBytes(optBytes);

        ref.read(mguDependentFileProvider.notifier).state = optFile;
      } else {
        ref.read(mguShowDependentOptionalProvider.notifier).state = false;
        ref.read(mguDependentFileProvider.notifier).state = null;
        _deskripsiController.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data gambar berhasil dimuat. Silakan edit.'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // Jika gagal, mungkin reset mode edit agar tidak stuck
      // ref.read(mguEditingGambarProvider.notifier).state = null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // ------------------------------------------

  void _resetForm() {
    ref.read(mguSelectedMasterDataIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyNameProvider.notifier).state = null;

    ref.read(mguGambarUtamaFileProvider.notifier).state = null;
    ref.read(mguGambarTeruraiFileProvider.notifier).state = null;
    ref.read(mguGambarKontruksiFileProvider.notifier).state = null;

    ref.read(mguShowDependentOptionalProvider.notifier).state = false;
    ref.read(mguDependentFileProvider.notifier).state = null;

    // Reset mode edit juga
    ref.read(mguEditingGambarProvider.notifier).state = null;

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
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      // Setelah sukses, reset form (keluar dari mode edit)
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
}
