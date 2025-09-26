import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_kelistrikan_section.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_optional_section.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_synced_row.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_utama_row.dart';

class GambarMainForm extends ConsumerWidget {
  final Transaksi transaksi;
  final Function(int) onPreviewPressed;

  const GambarMainForm({
    super.key,
    required this.transaksi,
    required this.onPreviewPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil semua state yang dibutuhkan untuk perhitungan
    final jumlahGambarUtama = ref.watch(jumlahGambarProvider);
    final showOptional = ref.watch(showGambarOptionalProvider);
    final jumlahGambarOptional = ref.watch(jumlahGambarOptionalProvider);
    final showKelistrikan = ref.watch(showGambarKelistrikanProvider);

    // --- LOGIKA PERHITUNGAN HALAMAN YANG DIPERBAIKI ---
    int totalHalaman = jumlahGambarUtama * 3;
    if (showOptional) {
      totalHalaman += jumlahGambarOptional;
    }
    if (showKelistrikan) {
      totalHalaman++;
    }

    // Nomor halaman awal untuk section optional
    int optionalBasePageNumber = jumlahGambarUtama * 3 + 1;

    // Nomor halaman untuk section kelistrikan, dihitung setelah optional
    int kelistrikanPageNumber =
        jumlahGambarUtama * 3 + (showOptional ? jumlahGambarOptional : 0) + 1;
    // ---------------------------------------------------

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Gambar Utama',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) => GambarUtamaRow(
                index: index,
                transaksi: transaksi,
                totalHalaman: totalHalaman,
                onPreviewPressed: () => onPreviewPressed(index),
              ),
            ),
            const Divider(height: 32),
            _buildSection(
              title: 'Gambar Terurai',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) => GambarSyncedRow(
                index: index,
                title: 'Gambar Terurai',
                transaksi: transaksi,
                totalHalaman: totalHalaman,
                onPreviewPressed: () => onPreviewPressed(index),
              ),
            ),
            const Divider(height: 32),
            _buildSection(
              title: 'Gambar Kontruksi',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) => GambarSyncedRow(
                index: index,
                title: 'Gambar Kontruksi',
                transaksi: transaksi,
                totalHalaman: totalHalaman,
                onPreviewPressed: () => onPreviewPressed(index),
              ),
            ),
            const Divider(height: 32),
            CheckboxListTile(
              title: const Text("Tampilkan Gambar Optional"),
              value: showOptional,
              onChanged: (value) =>
                  ref.read(showGambarOptionalProvider.notifier).state = value!,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (showOptional) ...[
              GambarOptionalSection(
                basePageNumber: optionalBasePageNumber,
                totalHalaman: totalHalaman,
                onPreviewPressed: onPreviewPressed,
              ),
              const SizedBox(height: 16),
            ],
            CheckboxListTile(
              title: const Text("Tampilkan Gambar Kelistrikan"),
              value: showKelistrikan,
              onChanged: (value) =>
                  ref.read(showGambarKelistrikanProvider.notifier).state =
                      value!,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (showKelistrikan)
              GambarKelistrikanSection(
                transaksi: transaksi,
                pageNumber: kelistrikanPageNumber,
                totalHalaman: totalHalaman,
                onPreviewPressed: () =>
                    onPreviewPressed(kelistrikanPageNumber - 1),
              ),
          ],
        ),
      ),
    );
  }

  // Method _buildSection tetap di sini karena digunakan berkali-kali
  Widget _buildSection({
    required String title,
    required int itemCount,
    required Widget Function(int index) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) => itemBuilder(index),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ],
    );
  }
}
