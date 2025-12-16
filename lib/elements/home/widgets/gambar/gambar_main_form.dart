import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_kelistrikan_section.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_synced_row.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_utama_row.dart';

class GambarMainForm extends ConsumerWidget {
  final Transaksi transaksi;
  final Function(int pageNumber) onPreviewPressed;
  final int jumlahGambarUtama;

  // Tambahkan Parameter Controller
  final TextEditingController? deskripsiController;

  const GambarMainForm({
    super.key,
    required this.transaksi,
    required this.onPreviewPressed,
    required this.jumlahGambarUtama,
    this.deskripsiController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jenisPengajuan = transaksi.fPengajuan.jenisPengajuan.toUpperCase();
    final bool showDeskripsiOptional =
        jenisPengajuan == 'VARIAN' || jenisPengajuan == 'REVISI';
    final kelistrikanInfo = ref.watch(kelistrikanInfoProvider);
    // LOGIKA BARU: Dianggap "Ada" (dihitung halamannya) HANYA jika status 'ready'
    final hasKelistrikan =
        kelistrikanInfo != null && kelistrikanInfo['status_code'] == 'ready';

    final independentOptionals = ref.watch(automaticIndependenOptionsProvider);
    final dependentOptionals = ref.watch(dependentOptionalOptionsProvider);

    final dependentCount = dependentOptionals.asData?.value.length ?? 0;
    final independentCount = independentOptionals.asData?.value.length ?? 0;

    // Hitung Halaman
    final int startPageTerurai = jumlahGambarUtama + 1;
    final int startPageKontruksi = startPageTerurai + jumlahGambarUtama;
    final int startPagePaket = startPageKontruksi + jumlahGambarUtama;
    final int startPageIndependen = startPagePaket + dependentCount;
    // Kelistrikan mulai setelah independen selesai
    final int pageKelistrikan = startPageIndependen + independentCount;

    // Total Halaman
    int totalHalaman = pageKelistrikan + (hasKelistrikan ? 0 : -1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Utama (Urutan: 1, 2, 3...)
            _buildSection(
              title: 'Gambar Utama',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) {
                final pageNumber = index + 1; // Rumus Baru
                return GambarUtamaRow(
                  index: index,
                  transaksi: transaksi,
                  totalHalaman: totalHalaman,
                  pageNumber: pageNumber,
                  onPreviewPressed: () => onPreviewPressed(pageNumber),
                );
              },
            ),
            const Divider(height: 10),
            _buildSection(
              title: 'Gambar Terurai',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) {
                final pageNumber = startPageTerurai + index; // Rumus Baru
                return GambarSyncedRow(
                  index: index,
                  title: 'Gambar Terurai',
                  transaksi: transaksi,
                  totalHalaman: totalHalaman,
                  jumlahGambarUtama: jumlahGambarUtama,
                  pageNumber: pageNumber,
                  onPreviewPressed: () => onPreviewPressed(pageNumber),
                );
              },
            ),
            const Divider(height: 10),
            _buildSection(
              title: 'Gambar Kontruksi',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) {
                final pageNumber = startPageKontruksi + index; // Rumus Baru
                return GambarSyncedRow(
                  index: index,
                  title: 'Gambar Kontruksi',
                  transaksi: transaksi,
                  totalHalaman: totalHalaman,
                  jumlahGambarUtama: jumlahGambarUtama,
                  pageNumber: pageNumber,
                  onPreviewPressed: () => onPreviewPressed(pageNumber),
                );
              },
            ),
            dependentOptionals.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    const Divider(height: 32),
                    _buildSection(
                      title: 'Gambar Optional Paket',
                      itemCount: items.length,
                      itemBuilder: (index) {
                        final item = items[index];
                        final pageNumber = startPagePaket + index; // Rumus Baru
                        ref.watch(pemeriksaIdProvider) != null;
                        final isLoading = ref.watch(isProcessingProvider);
                        return Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text('Optional Paket ${index + 1}:'),
                            ),
                            Expanded(
                              flex: 6, // Beri ruang lebih untuk deskripsi
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(item.name),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 70,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Center(
                                  child: Text('$pageNumber/$totalHalaman'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 170, // Sesuai permintaan Anda
                              child: ElevatedButton(
                                onPressed: !isLoading
                                    ? () => onPreviewPressed(pageNumber)
                                    : null,
                                child: const Text('Preview Gambar'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Text('Error: $err'),
            ),
            // const Divider(height: 10),
            independentOptionals.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    const Divider(height: 32),
                    _buildSection(
                      title: 'Gambar Optional Independen',
                      itemCount: items.length,
                      itemBuilder: (index) {
                        final item = items[index];
                        final pageNumber = startPageIndependen + index;
                        final isPreviewEnabled =
                            ref.watch(pemeriksaIdProvider) != null;
                        final isLoading = ref.watch(isProcessingProvider);

                        return Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text('Gambar\nIndependen ${index + 1}:'),
                            ),
                            Expanded(
                              flex: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .green
                                      .shade50, // Pembeda warna dikit
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(item.name),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 70,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Center(
                                  child: Text('$pageNumber/$totalHalaman'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 170,
                              child: ElevatedButton(
                                onPressed: isPreviewEnabled && !isLoading
                                    ? () => onPreviewPressed(pageNumber)
                                    : null,
                                child: const Text('Preview Gambar'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
            const Divider(height: 10),

            GambarKelistrikanSection(
              transaksi: transaksi,
              pageNumber: pageKelistrikan, // Rumus Baru
              totalHalaman: totalHalaman,
              onPreviewPressed: () => onPreviewPressed(pageKelistrikan),
            ),
            if (showDeskripsiOptional) ...[
              const Divider(height: 32),
              const Text(
                'Deskripsi Optional (Untuk Varian/Revisi)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                // Gunakan controller jika ada, jika tidak null (tapi harusnya ada dari screen)
                controller: deskripsiController,

                // Hapus initialValue karena bentrok dengan controller
                // initialValue: ref.watch(deskripsiOptionalProvider),
                onChanged: (value) =>
                    ref.read(deskripsiOptionalProvider.notifier).state = value,

                decoration: const InputDecoration(
                  hintText: 'Masukkan deskripsi tambahan di sini...',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ],
        ),
      ),
    );
  }

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
