// File: lib/elements/home/screens/permohonan_skrb_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/skrb.dart';
import 'package:master_gambar/elements/home/providers/transaksi_providers.dart';
import '../providers/page_state_provider.dart';
import '../providers/skrb_providers.dart';
import '../widgets/skrb/permohonan_skrb_table.dart';
import '../widgets/skrb/skrb_advanced_filter_panel.dart';
import '../widgets/skrb/tambah_permohonan_skrb_dialog.dart';

class PermohonanSkrbScreen extends ConsumerStatefulWidget {
  const PermohonanSkrbScreen({super.key});

  @override
  ConsumerState<PermohonanSkrbScreen> createState() =>
      _PermohonanSkrbScreenState();
}

class _PermohonanSkrbScreenState extends ConsumerState<PermohonanSkrbScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(skrbFilterProvider.notifier).state = {};
    });
  }

  Future<void> _openTambahSkrbDialog() async {
    final newSkrb = await showDialog<Skrb?>(
      context: context,
      builder: (_) => const TambahPermohonanSkrbDialog(),
    );

    if (newSkrb != null && mounted) {
      ref.invalidate(skrbListProvider);
      ref.invalidate(availableTransactionsProvider);
      _showSkrbCreatedSnackbar(newSkrb);

      ref.invalidate(skrbDetailProvider(newSkrb.id));
      ref.read(pageStateProvider.notifier).state = PageState(
        pageIndex: 3,
        skrbId: newSkrb.id,
      );
    }
  }

  void _showSkrbCreatedSnackbar(Skrb skrb) {
    if (!mounted) {
      return;
    }
    if (skrb.alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SKRB ini sudah ada (${skrb.idSkrb}). Mengalihkan ke Detail SKRB.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (skrb.idSkrb.contains('-SKRB') && skrb.idSkrb.contains('/x')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SKRB dibuat dengan ID sementara: ${skrb.idSkrb}\nPERHATIAN: "Permohonan SKRB" Customer belum diisi admin!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 10),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permohonan SKRB berhasil dibuat: ${skrb.idSkrb}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 0),
        child: Column(
          children: [
            // 1. Filter Lanjutan
            const SkrbAdvancedFilterPanel(),
            const SizedBox(height: 1),

            // 2. Baris Kontrol Header (Judul di kiri, Tombol Tambah & Reload di kanan)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 12),
                // Sebelah kiri: Judul
                const Text(
                  "Permohonan SKRB",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Sebelah kanan: Button Tambah & Reload button
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text(
                    'Tambah Permohonan SKRB Baru',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _openTambahSkrbDialog(),
                ),
                const SizedBox(width: 10),
                Tooltip(
                  message: 'Refresh Tabel Permohonan SKRB',
                  child: InkWell(
                    onTap: () {
                      ref.invalidate(skrbListProvider);
                      ref.invalidate(availableTransactionsProvider);
                      ref.invalidate(jenisPengajuanOptionsProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Memuat ulang tabel dan data SKRB...'),
                          duration: Duration(milliseconds: 1200),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.refresh, size: 19),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // 3. Tabel Permohonan SKRB
            const Expanded(
              child: Card(
                child: SizedBox(
                  width: double.infinity,
                  child: PermohonanSkrbTable(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
