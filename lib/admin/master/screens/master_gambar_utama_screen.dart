import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:master_gambar/admin/master/models/g_gambar_utama.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:path_provider/path_provider.dart';
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
  void initState() {
    super.initState();
    // Cek apakah ada data edit saat pertama kali masuk (antisipasi navigasi cepat)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editingData = ref.read(mguEditingGambarProvider);
      if (editingData != null) {
        _loadExistingData(editingData);
      }
    });
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- LOGIKA MEMUAT DATA LAMA (PREVIEW & RE-UPLOAD) ---
  Future<void> _loadExistingData(GGambarUtama gambarUtama) async {
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(masterDataRepositoryProvider);

      // 1. Dapatkan Path dari Server
      final paths = await repo.getGambarUtamaPaths(gambarUtama.id);

      // 2. Helper: Download PDF ke Temp agar dianggap sebagai "File yang dipilih"
      Future<File> downloadToTemp(String path, String filename) async {
        final bytes = await repo.getPdfFromPath(path);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(bytes);
        return file;
      }

      // 3. Download 3 Gambar Utama secara paralel
      final results = await Future.wait([
        downloadToTemp(paths['utama']!, 'existing_utama.pdf'),
        downloadToTemp(paths['terurai']!, 'existing_terurai.pdf'),
        downloadToTemp(paths['kontruksi']!, 'existing_kontruksi.pdf'),
      ]);

      // 4. Isi Provider File (Otomatis akan mentrigger Preview di Card)
      ref.read(mguGambarUtamaFileProvider.notifier).state = results[0];
      ref.read(mguGambarTeruraiFileProvider.notifier).state = results[1];
      ref.read(mguGambarKontruksiFileProvider.notifier).state = results[2];

      // 5. Cek Gambar Paket Optional
      // Logic: Filter list gambarOptionals, cari yang tipe == 'paket'
      final paketOptional = gambarUtama.gambarOptionals
          .where((g) => g.tipe == 'paket')
          .firstOrNull;

      if (paketOptional != null) {
        // A. Centang Checkbox
        ref.read(mguShowDependentOptionalProvider.notifier).state = true;

        // B. Isi Deskripsi
        _deskripsiController.text = paketOptional.deskripsi;

        // C. Download & Isi File Optional
        // Kita gunakan repo.getPdfFromPath dengan path dari model (atau via ID jika ada endpoint khusus)
        // Asumsi: path di model valid untuk endpoint viewPdf
        final optBytes = await repo.getPdfFromPath(paketOptional.path);
        final tempDir = await getTemporaryDirectory();
        final optFile = File('${tempDir.path}/existing_paket.pdf');
        await optFile.writeAsBytes(optBytes);

        ref.read(mguDependentFileProvider.notifier).state = optFile;
      } else {
        // Reset jika tidak ada paket
        ref.read(mguShowDependentOptionalProvider.notifier).state = false;
        ref.read(mguDependentFileProvider.notifier).state = null;
        _deskripsiController.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data lama berhasil dimuat. Silakan review/ganti.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat gambar lama: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listener untuk perubahan mode edit realtime
    ref.listen<GGambarUtama?>(mguEditingGambarProvider, (prev, next) {
      if (next != null) {
        _loadExistingData(next);
      }
    });

    final showDependent = ref.watch(mguShowDependentOptionalProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // JUDUL TETAP SAMA (Sesuai request)
              const Text(
                'Manajemen Gambar Utama',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset Form',
                onPressed: _resetAndRefresh,
              ),
            ],
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            const SizedBox(height: 16),

            // Card Dropdown akan otomatis terisi karena mendengarkan initialGambarUtamaDataProvider
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

            // Card File PDF akan otomatis menampilkan preview file lama
            // karena provider file sudah diisi di _loadExistingData
            PilihFilePdfCard(onSubmit: _submit, isLoading: _isLoading),
          ],
        ],
      ),
    );
  }

  void _resetForm() {
    ref.read(mguSelectedMasterDataIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
    ref.read(mguSelectedVarianBodyNameProvider.notifier).state = null;

    ref.read(mguGambarUtamaFileProvider.notifier).state = null;
    ref.read(mguGambarTeruraiFileProvider.notifier).state = null;
    ref.read(mguGambarKontruksiFileProvider.notifier).state = null;

    ref.read(mguShowDependentOptionalProvider.notifier).state = false;
    ref.read(mguDependentFileProvider.notifier).state = null;
    ref.read(mguEditingGambarProvider.notifier).state =
        null; // Keluar mode edit

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

    if (selectedMasterDataId == null ||
        selectedVarianBodyName == null ||
        gambarUtamaFile == null ||
        gambarTeruraiFile == null ||
        gambarKontruksiFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data belum lengkap (Master Data / File Utama).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (showDependent &&
        (_deskripsiController.text.isEmpty || dependentFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data Optional Paket belum lengkap.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Upload (Akan menimpa file lama di server karena nama file di backend distandarisasi)
      final gambarUtama = await ref
          .read(masterDataRepositoryProvider)
          .uploadGambarUtamaWithResult(
            masterDataId: selectedMasterDataId,
            varianBodyName: selectedVarianBodyName,
            gambarUtama: gambarUtamaFile,
            gambarTerurai: gambarTeruraiFile,
            gambarKontruksi: gambarKontruksiFile,
          );

      // 2. Handle Optional Paket
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
          content: Text('Gambar berhasil disimpan/diupdate!'),
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
}
