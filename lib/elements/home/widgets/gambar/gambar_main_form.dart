// File: lib/elements/home/widgets/gambar/gambar_main_form.dart

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
        kelistrikanInfo != null && kelistrikanInfo['status_code'] == 'ready';

    final independentStateAsync = ref.watch(independentListNotifierProvider);
    final dependentOptionals = ref.watch(dependentOptionalOptionsProvider);

    final dependentCount = dependentOptionals.asData?.value.length ?? 0;
    final activeIndependentCount =
        independentStateAsync.value?.activeItems.length ?? 0;
    // 5. Hitung Halaman
    final int startPageTerurai = jumlahGambarUtama + 1;
    final int startPageKontruksi = startPageTerurai + jumlahGambarUtama;
    final int startPagePaket = startPageKontruksi + jumlahGambarUtama;
    final int startPageIndependen = startPagePaket + dependentCount;
    final int pageKelistrikan = startPageIndependen + activeIndependentCount;

    int totalHalaman = isGambarTU
        ? jumlahGambarUtama
        : pageKelistrikan + (hasKelistrikan ? 0 : -1);

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
              // 5. Gambar Optional Independen (ACTIVE & HIDDEN)
              independentStateAsync.when(
                data: (independentState) {
                  final activeItems = independentState.activeItems;
                  final hiddenItems = independentState.hiddenItems;

                  // Jika kedua list kosong, sembunyikan section ini
                  if (activeItems.isEmpty && hiddenItems.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 32),

                      // --- HEADER SECTION ---
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
                                'Geser icon titik-titik untuk mengubah urutan halaman.\n'
                                'Tekan icon mata coret untuk menyembunyikan gambar.',
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

                      // Pesan jika list aktif kosong tapi ada yang di-hide
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
                            'Buka menu "Gambar Disembunyikan" di bawah untuk menambahkan gambar.',
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
                          // Penting agar tidak bentrok dengan scroll parent
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles:
                              false, // Kita pakai custom handle
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

                            return ReorderableDragStartListener(
                              key: ValueKey(item.id),
                              index: index,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // 1. Drag Handle
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.drag_indicator,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    // 2. Nama Item
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            // Badge Halaman
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.yellow.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: Colors.orange.shade200,
                                                ),
                                              ),
                                              child: Text(
                                                'Hal $pageNumber / $totalHalaman',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange.shade900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 3. Action Buttons
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Tombol Preview
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility,
                                            color: Colors.blue,
                                          ),
                                          tooltip: 'Preview Gambar',
                                          onPressed:
                                              isPreviewEnabled && !isLoading
                                              ? () =>
                                                    onPreviewPressed(pageNumber)
                                              : null,
                                        ),

                                        // Tombol Hide (Pindah ke bawah)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                          tooltip:
                                              'Sembunyikan (Tidak ikut diproses)',
                                          onPressed: () {
                                            ref
                                                .read(
                                                  independentListNotifierProvider
                                                      .notifier,
                                                )
                                                .hideItem(item);
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      // Tampilan Read-Only (Mode View)
                      else if (!isEditMode && activeItems.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeItems.length,
                          itemBuilder: (context, index) {
                            final item = activeItems[index];
                            final pageNumber = startPageIndependen + index;
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                title: Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$pageNumber/$totalHalaman',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 13,
                                    ),
                                    minimumSize: const Size(80, 32),
                                  ),
                                  onPressed: () => onPreviewPressed(pageNumber),
                                  child: const Text('Preview Gambar'),
                                ),
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
                            // Hilangkan garis divider default ExpansionTile
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: activeItems
                                  .isEmpty, // Auto expand jika list atas kosong
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
                              subtitle: const Text(
                                'Klik untuk membuka dan menambahkan ke list cetak',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
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
                                      trailing: TextButton.icon(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        label: const Text(
                                          'Pakai',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
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
