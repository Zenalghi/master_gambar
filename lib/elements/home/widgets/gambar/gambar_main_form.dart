// File: lib/elements/home/widgets/gambar/gambar_main_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_kelistrikan_section.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_synced_row.dart';
import 'package:master_gambar/elements/home/widgets/gambar/gambar_utama_row.dart';

import '../../../../admin/master/repository/master_data_repository.dart';
import '../../../../admin/master/widgets/pdf_viewer_dialog.dart';

class GambarMainForm extends ConsumerWidget {
  final Transaksi transaksi;
  final Function(int pageNumber) onPreviewPressed;
  final int jumlahGambarUtama;
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
    // 1. Tentukan Jenis Pengajuan
    final jenisPengajuan = transaksi.fPengajuan.jenisPengajuan.toUpperCase();

    // 2. Logika Khusus 'GAMBAR TU' (Hanya Gambar Utama)
    final bool isGambarTU = jenisPengajuan == 'GAMBAR TU';

    // 3. Logika Tampil Deskripsi Optional (Varian, Revisi, Baru)
    final bool showDeskripsiOptional =
        jenisPengajuan == 'VARIAN' ||
        jenisPengajuan == 'REVISI' ||
        jenisPengajuan == 'BARU';

    // 4. Ambil Data Provider
    final kelistrikanInfo = ref.watch(kelistrikanInfoProvider);
    final hasKelistrikan =
        kelistrikanInfo != null &&
        (kelistrikanInfo['status_code'] == 'ready' ||
            kelistrikanInfo['status_code'] == 'multiple_options');

    final independentStateAsync = ref.watch(independentListNotifierProvider);
    final dependentOptionals = ref.watch(dependentOptionalOptionsProvider);

    final dependentCount = dependentOptionals.asData?.value.length ?? 0;

    // Gunakan asData untuk akses value yang aman
    final activeIndependentCount =
        independentStateAsync.asData?.value.activeItems.length ?? 0;

    // 5. Hitung Halaman (LOGIKA FIXED)
    final int startPageTerurai = jumlahGambarUtama + 1;
    final int startPageKontruksi = startPageTerurai + jumlahGambarUtama;
    final int startPagePaket = startPageKontruksi + jumlahGambarUtama;
    final int startPageIndependen = startPagePaket + dependentCount;

    // Halaman Kelistrikan selalu setelah semua halaman independen selesai
    final int pageKelistrikan = startPageIndependen + activeIndependentCount;

    // Total Halaman
    // Jika tidak ada kelistrikan, totalnya adalah halaman terakhir independen (pageKelistrikan - 1)
    // Jika ada kelistrikan, totalnya adalah pageKelistrikan itu sendiri
    int totalHalaman = isGambarTU
        ? jumlahGambarUtama
        : (hasKelistrikan ? pageKelistrikan : (pageKelistrikan - 1));

    final isEditMode = ref.watch(isEditModeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Gambar Utama (SELALU ADA) ---
            _buildSection(
              title: 'Gambar Utama',
              itemCount: jumlahGambarUtama,
              itemBuilder: (index) {
                final pageNumber = index + 1;
                return GambarUtamaRow(
                  index: index,
                  transaksi: transaksi,
                  totalHalaman: totalHalaman,
                  pageNumber: pageNumber,
                  onPreviewPressed: () => onPreviewPressed(pageNumber),
                );
              },
            ),

            // --- JIKA BUKAN 'GAMBAR TU', TAMPILKAN SEMUANYA ---
            if (!isGambarTU) ...[
              const Divider(height: 10),

              // 2. Gambar Terurai
              _buildSection(
                title: 'Gambar Terurai',
                itemCount: jumlahGambarUtama,
                itemBuilder: (index) {
                  final pageNumber = startPageTerurai + index;
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

              // 3. Gambar Kontruksi
              _buildSection(
                title: 'Gambar Kontruksi',
                itemCount: jumlahGambarUtama,
                itemBuilder: (index) {
                  final pageNumber = startPageKontruksi + index;
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

              // 4. Gambar Optional Paket
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
                          final pageNumber = startPagePaket + index;
                          final isLoading = ref.watch(isProcessingProvider);
                          return Row(
                            children: [
                              SizedBox(
                                width: 150,
                                child: Text('Optional Paket ${index + 1}:'),
                              ),
                              Expanded(
                                flex: 6,
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
                                width: 170,
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

              // 5. Gambar Optional Independen
              independentStateAsync.when(
                data: (independentState) {
                  final activeItems = independentState.activeItems;
                  final hiddenItems = independentState.hiddenItems;

                  if (activeItems.isEmpty && hiddenItems.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 32),

                      // --- HEADER ---
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
                          const SizedBox(width: 4),
                          Tooltip(
                            message:
                                'Gambar di list atas AKAN DICETAK.\n'
                                'Gambar di list bawah DISEMBUNYIKAN.',
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Pesan jika list aktif kosong
                      if (activeItems.isEmpty && hiddenItems.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: const Text(
                            'Tidak ada gambar optional yang dipilih untuk dicetak.\n'
                            'Buka menu "Gambar Disembunyikan" di bawah untuk menambahkan.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.brown,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      // --- BAGIAN 1: LIST AKTIF (Reorderable) ---
                      if (isEditMode && activeItems.isNotEmpty)
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: activeItems.length,
                          onReorder: (oldIndex, newIndex) {
                            ref
                                .read(independentListNotifierProvider.notifier)
                                .reorder(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final item = activeItems[index];
                            final pageNumber = startPageIndependen + index;
                            final isPreviewEnabled =
                                ref.watch(pemeriksaIdProvider) != null;
                            final isLoading = ref.watch(isProcessingProvider);

                            return Container(
                              key: ValueKey(item.id),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  // BAGIAN KIRI: NAMA & DRAG
                                  Expanded(
                                    child: ReorderableDragStartListener(
                                      index: index,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.drag_indicator,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.visibility_off,
                                                color: Colors.grey,
                                              ),
                                              tooltip: 'Sembunyikan',
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      independentListNotifierProvider
                                                          .notifier,
                                                    )
                                                    .hideItem(item);
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // BAGIAN KANAN: NOMOR & PREVIEW
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
                                        child: Text(
                                          '$pageNumber/$totalHalaman',
                                        ),
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
                              ),
                            );
                          },
                        )
                      // View Mode (Read Only)
                      else if (!isEditMode && activeItems.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeItems.length,
                          itemBuilder: (context, index) {
                            final item = activeItems[index];
                            final pageNumber = startPageIndependen + index;
                            final isPreviewEnabled =
                                ref.watch(pemeriksaIdProvider) != null;
                            final isLoading = ref.watch(isProcessingProvider);

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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
                                        child: Text(
                                          '$pageNumber/$totalHalaman',
                                        ),
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
                              ),
                            );
                          },
                        ),

                      // --- BAGIAN 2: LIST HIDDEN (Hanya di Mode Edit) ---
                      if (isEditMode && hiddenItems.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: activeItems.isEmpty,
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              leading: Icon(
                                Icons.archive_outlined,
                                color: Colors.grey.shade600,
                              ),
                              title: Text(
                                'Gambar Disembunyikan (${hiddenItems.length})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                const Divider(height: 1),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: hiddenItems.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = hiddenItems[index];
                                    final isLoading = ref.watch(
                                      isProcessingProvider,
                                    );

                                    return ListTile(
                                      dense: true,
                                      contentPadding: const EdgeInsets.only(
                                        left: 16,
                                        right: 8,
                                      ),
                                      title: Text(
                                        item.name,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      // --- ACTION BUTTONS (Preview & Pakai) ---
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // 1. Button Preview
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.visibility,
                                              size: 16,
                                              color: Colors.blue,
                                            ),
                                            label: const Text(
                                              'Preview',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                            ),
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    // Logic Preview File Mentah via Repository
                                                    try {
                                                      // Tampilkan Loading (opsional)
                                                      final bytes = await ref
                                                          .read(
                                                            masterDataRepositoryProvider,
                                                          )
                                                          .getGambarOptionalPdf(
                                                            item.id as int,
                                                          );

                                                      if (context.mounted) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (ctx) =>
                                                              PdfViewerDialog(
                                                                pdfData: bytes,
                                                                title:
                                                                    'Preview: ${item.name}\nDeskripsi dicetak pada saat dipakai',
                                                              ),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Gagal preview: $e',
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                          ),
                                          const SizedBox(width: 8),

                                          // 2. Button Pakai
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.add_circle,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                            label: const Text(
                                              'Pakai',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    independentListNotifierProvider
                                                        .notifier,
                                                  )
                                                  .unhideItem(item);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Gagal memuat list optional: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const Divider(height: 10),

              // 6. Kelistrikan
              GambarKelistrikanSection(
                transaksi: transaksi,
                pageNumber: pageKelistrikan,
                totalHalaman: totalHalaman,
                onPreviewPressed: () => onPreviewPressed(pageKelistrikan),
              ),
            ],

            // --- 7. Deskripsi Optional (Kondisional) ---
            if (showDeskripsiOptional) ...[
              const Divider(height: 32),
              const Text(
                'Deskripsi Optional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                enabled: isEditMode,
                controller: deskripsiController,
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
