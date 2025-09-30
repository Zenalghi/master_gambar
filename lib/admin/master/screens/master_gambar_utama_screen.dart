import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/providers/master_data_providers.dart';
import 'package:master_gambar/admin/master/repository/master_data_repository.dart';
import 'package:dio/dio.dart';
import '../widgets/pilih_file_pdf_card.dart';
import '../widgets/pilih_varian_body_card.dart';

class MasterGambarUtamaScreen extends ConsumerStatefulWidget {
  const MasterGambarUtamaScreen({super.key});
  @override
  ConsumerState<MasterGambarUtamaScreen> createState() =>
      _MasterGambarUtamaScreenState();
}

class _MasterGambarUtamaScreenState
    extends ConsumerState<MasterGambarUtamaScreen> {
  bool _isLoading = false;

  Future<void> _submit() async {
    final selectedVarianBodyId = ref.read(mguSelectedVarianBodyIdProvider);
    final gambarUtamaFile = ref.read(mguGambarUtamaFileProvider);
    final gambarTeruraiFile = ref.read(mguGambarTeruraiFileProvider);
    final gambarKontruksiFile = ref.read(mguGambarKontruksiFileProvider);

    if (selectedVarianBodyId == null ||
        gambarUtamaFile == null ||
        gambarTeruraiFile == null ||
        gambarKontruksiFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua field dan pilih semua file PDF.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(masterDataRepositoryProvider)
          .uploadGambarUtama(
            varianBodyId: selectedVarianBodyId,
            gambarUtama: gambarUtamaFile,
            gambarTerurai: gambarTeruraiFile,
            gambarKontruksi: gambarKontruksiFile,
          );

      // Reset semua state provider setelah berhasil
      ref.read(mguSelectedTypeEngineIdProvider.notifier).state = null;
      ref.read(mguSelectedMerkIdProvider.notifier).state = null;
      ref.read(mguSelectedTypeChassisIdProvider.notifier).state = null;
      ref.read(mguSelectedJenisKendaraanIdProvider.notifier).state = null;
      ref.read(mguSelectedVarianBodyIdProvider.notifier).state = null;
      ref.read(mguGambarUtamaFileProvider.notifier).state = null;
      ref.read(mguGambarTeruraiFileProvider.notifier).state = null;
      ref.read(mguGambarKontruksiFileProvider.notifier).state = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gambar Utama berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.response?.data['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Gambar Utama',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const PilihVarianBodyCard(), // <-- Panggil widget Card 1
          const SizedBox(height: 16),
          PilihFilePdfCard(
            // <-- Panggil widget Card 2
            onSubmit: _submit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
