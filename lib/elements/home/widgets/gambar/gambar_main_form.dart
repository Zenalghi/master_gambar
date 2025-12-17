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
    final independentAsync = ref.watch(independentListNotifierProvider);
    // final independentOptionals = ref.watch(automaticIndependenOptionsProvider);
    final dependentOptionals = ref.watch(dependentOptionalOptionsProvider);

    final dependentCount = dependentOptionals.asData?.value.length ?? 0;
    final independentCount = independentAsync.asData?.value.length ?? 0;
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
            independentAsync.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Text(
                          'Gambar Optional Independen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        //icon info
                        const SizedBox(width: 4),
                        Tooltip(
                          message:
                              'Urutan gambar independen dengan cara drag & drop.',
                          child: const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // WIDGET DRAG & DROP
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Agar scroll ikut parent
                      // Agar list tidak terlihat aneh saat di-drag (opsional)
                      buildDefaultDragHandles:
                          false, // Kita buat handle custom (atau bungkus seluruh row)

                      itemCount: items.length,
                      onReorder: (oldIndex, newIndex) {
                        ref
                            .read(independentListNotifierProvider.notifier)
                            .reorder(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final pageNumber = startPageIndependen + index;
                        final isLoading = ref.watch(isProcessingProvider);

                        return ReorderableDragStartListener(
                          key: ValueKey(item.id), // ID Unik Item
                          index: index,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors
                                  .white, // Background putih agar terlihat saat di-drag
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                // AREA DRAG (KIRI SAMPAI TEKS DESKRIPSI)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        // Icon Drag Handle (Opsional, sebagai indikator visual saja)
                                        const Icon(
                                          Icons.drag_indicator,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 8),

                                        SizedBox(
                                          width: 110,
                                          child: Text(
                                            'Gambar\nOptional ${index + 1}:',
                                          ),
                                        ),

                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: Colors.green.shade100,
                                              ),
                                            ),
                                            child: Text(item.name),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // AREA NON-DRAG (KANAN: HALAMAN & TOMBOL)
                                // Kita pisahkan agar interaksi tombol tidak terganggu
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      // Indikator Halaman
                                      SizedBox(
                                        width: 70,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.shade200,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$pageNumber/$totalHalaman',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Tombol Preview
                                      SizedBox(
                                        width: 160,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          onPressed: !isLoading
                                              ? () =>
                                                    onPreviewPressed(pageNumber)
                                              : null,
                                          child: const Text('Preview Gambar'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading options: $err'),
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
