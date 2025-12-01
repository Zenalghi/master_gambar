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
  final Function(int pageNumber) onPreviewPressed;
  final int jumlahGambarUtama;

  const GambarMainForm({
    super.key,
    required this.transaksi,
    required this.onPreviewPressed,
    required this.jumlahGambarUtama,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jenisPengajuan = transaksi.fPengajuan.jenisPengajuan.toUpperCase();
    final bool showDeskripsiOptional =
        jenisPengajuan == 'VARIAN' || jenisPengajuan == 'REVISI';
    final showOptional = ref.watch(showGambarOptionalProvider);
    final jumlahGambarOptional = ref.watch(jumlahGambarOptionalProvider);
    final kelistrikanAsync = ref.watch(
      gambarKelistrikanDataProvider(transaksi.cTypeChassis.id),
    );
    final hasKelistrikan = kelistrikanAsync.asData?.value != null;
    final dependentOptionals = ref.watch(dependentOptionalOptionsProvider);
    final dependentCount = dependentOptionals.asData?.value.length ?? 0;

    int totalHalaman =
        (jumlahGambarUtama * 3) +
        dependentCount +
        (showOptional ? jumlahGambarOptional : 0) +
        (hasKelistrikan ? 1 : 0);
    int dependentBasePageNumber = (jumlahGambarUtama * 3) + 1;
    int optionalBasePageNumber = dependentBasePageNumber + dependentCount;
    int kelistrikanPageNumber =
        optionalBasePageNumber + (showOptional ? jumlahGambarOptional : 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama (Sudah Benar)
            _buildSection(
              title: 'Gambar Utama',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) {
                // Rumus: (index * 3) + 1
                final pageNumber = (index * 3) + 1;
                return GambarUtamaRow(
                  index: index,
                  transaksi: transaksi,
                  totalHalaman: totalHalaman,
                  pageNumber:
                      pageNumber, // <-- Kirim nomor halaman untuk ditampilkan
                  onPreviewPressed: () => onPreviewPressed(
                    pageNumber,
                  ), // <-- Kirim nomor halaman yang benar
                );
              },
            ),
            const Divider(height: 10),
            // Gambar Terurai (Sudah Benar)
            _buildSection(
              title: 'Gambar Terurai',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) {
                // Rumus: (index * 3) + 2
                final pageNumber = (index * 3) + 2;
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
                // Rumus: (index * 3) + 3
                final pageNumber = (index * 3) + 3;
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
                if (items.isEmpty) {
                  return const SizedBox.shrink(); // Jangan tampilkan apa-apa jika kosong
                }
                // Jika ada data, tampilkan section-nya
                return Column(
                  children: [
                    const Divider(height: 32),
                    _buildSection(
                      title: 'Gambar Optional Paket',
                      itemCount: items.length,
                      itemBuilder: (index) {
                        final item = items[index];
                        final pageNumber = dependentBasePageNumber + index;
                        final isPreviewEnabled =
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
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Text('Error: $err'),
            ),
            const Divider(height: 10),
            CheckboxListTile(
              title: const Text("Tampilkan Gambar Optional Independen"),
              value: showOptional,
              onChanged: (value) =>
                  ref.read(showGambarOptionalProvider.notifier).state = value!,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (showOptional) ...[
              GambarOptionalSection(
                basePageNumber: optionalBasePageNumber,
                totalHalaman: totalHalaman,
                onPreviewPressed: (index) {
                  final pageNumber = optionalBasePageNumber + index;
                  onPreviewPressed(
                    pageNumber,
                  ); // Kirim nomor halaman yang sudah benar
                },
              ),
            ],
            const Divider(height: 10),

            GambarKelistrikanSection(
              transaksi: transaksi,
              pageNumber: kelistrikanPageNumber,
              totalHalaman: totalHalaman,
              onPreviewPressed: () => onPreviewPressed(kelistrikanPageNumber),
            ),
            if (showDeskripsiOptional) ...[
              const Divider(height: 32),
              Text(
                'Deskripsi Optional (Untuk Varian/Revisi)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: ref.watch(deskripsiOptionalProvider),
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
