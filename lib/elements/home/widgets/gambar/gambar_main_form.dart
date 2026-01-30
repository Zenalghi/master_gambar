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
    final bool isGambarTU = jenisPengajuan == 'GAMBAR TU';

    final bool showDeskripsiOptional =
        jenisPengajuan == 'VARIAN' ||
        jenisPengajuan == 'REVISI' ||
        jenisPengajuan == 'BARU';

    // 2. Ambil State Selection & Options (Untuk Cek Status File)
    final selections = ref.watch(gambarUtamaSelectionProvider);
    final isEditMode = ref.watch(isEditModeProvider);

    // Kita gunakan provider options untuk mengecek status 'hasTerurai' / 'hasKontruksi'
    final defaultParams = VarianFilterParams(
      search: '',
      masterDataId: transaksi.masterDataId,
    );
    final varianOptionsAsync = ref.watch(
      varianBodyStatusOptionsProvider(defaultParams),
    );

    // --- LOGIKA PERHITUNGAN HALAMAN DINAMIS ---

    // Struktur Data untuk menyimpan konfigurasi halaman setiap baris
    List<Map<String, dynamic>> finalPages = [];
    int currentPage = 1;

    // A. SETUP GAMBAR UTAMA (Selalu Ada dan Urut)
    for (int i = 0; i < jumlahGambarUtama; i++) {
      finalPages.add({
        'type': 'utama',
        'index': i,
        'page': currentPage++, // Halaman 1, 2, 3...
      });
    }

    // B. SETUP GAMBAR LAIN (Hanya jika bukan GAMBAR TU dan Data Options Tersedia)
    if (!isGambarTU && varianOptionsAsync.hasValue) {
      final options = varianOptionsAsync.value!;

      // -- TERURAI --
      // Loop sebanyak jumlah gambar utama untuk cek masing-masing varian
      List<Map<String, dynamic>> teruraiItems = [];
      for (int i = 0; i < jumlahGambarUtama; i++) {
        // Cek apakah user sudah memilih varian di index ini
        if (i < selections.length) {
          final selectedVarianId = selections[i].varianBodyId;
          if (selectedVarianId != null) {
            // Cari data varian di options untuk cek status file
            final varianData = options
                .where((e) => e.id == selectedVarianId)
                .firstOrNull;

            // Cek Flag hasTerurai (Pastikan model OptionItem sudah diupdate)
            if (varianData?.hasTerurai == true) {
              teruraiItems.add({
                'type': 'terurai',
                'index': i,
                // Page diisi nanti di loop bawah agar urut
              });
            }
          }
        }
      }
      // Assign nomor halaman untuk item yang valid
      for (var item in teruraiItems) {
        item['page'] = currentPage++;
        finalPages.add(item);
      }

      // -- KONTRUKSI --
      List<Map<String, dynamic>> kontruksiItems = [];
      for (int i = 0; i < jumlahGambarUtama; i++) {
        if (i < selections.length) {
          final selectedVarianId = selections[i].varianBodyId;
          if (selectedVarianId != null) {
            final varianData = options
                .where((e) => e.id == selectedVarianId)
                .firstOrNull;

            // Cek Flag hasKontruksi
            if (varianData?.hasKontruksi == true) {
              kontruksiItems.add({'type': 'kontruksi', 'index': i});
            }
          }
        }
      }
      for (var item in kontruksiItems) {
        item['page'] = currentPage++;
        finalPages.add(item);
      }
    }

    // C. PERHITUNGAN TOTAL HALAMAN UNTUK BAGIAN BAWAH
    // Variabel ini akan dipakai oleh widget anak (Optional & Kelistrikan)
    // untuk melanjutkan penomoran

    final dependentOptionals = ref.watch(dependentOptionalOptionsProvider);
    final dependentCount = dependentOptionals.asData?.value.length ?? 0;

    // Start page paket = halaman terakhir setelah kontruksi + 1
    // (currentPage saat ini sudah menunjuk ke next available page)
    final int startPagePaket = currentPage;

    // Update currentPage setelah paket
    currentPage += dependentCount;

    final independentStateAsync = ref.watch(independentListNotifierProvider);
    final activeIndependentCount =
        independentStateAsync.asData?.value.activeItems.length ?? 0;

    final int startPageIndependen = currentPage;

    // Update currentPage setelah independen
    currentPage += activeIndependentCount;

    // Halaman Kelistrikan
    final int pageKelistrikan = currentPage;

    final kelistrikanInfo = ref.watch(kelistrikanInfoProvider);
    final hasKelistrikan =
        kelistrikanInfo != null &&
        (kelistrikanInfo['status_code'] == 'ready' ||
            kelistrikanInfo['status_code'] == 'multiple_options');

    // Total Halaman Final untuk Label "1/X"
    // Jika ada kelistrikan, totalnya adalah pageKelistrikan. Jika tidak, kurangi 1.
    final int totalHalaman = hasKelistrikan
        ? pageKelistrikan
        : (pageKelistrikan - 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Gambar Utama (SELALU ADA) ---
            _buildSection(
              title: 'Gambar Utama',
              items: finalPages.where((e) => e['type'] == 'utama').toList(),
              itemBuilder: (item) {
                return GambarUtamaRow(
                  index: item['index'],
                  transaksi: transaksi,
                  totalHalaman: totalHalaman,
                  pageNumber: item['page'], // Halaman 1, 2, ...
                  onPreviewPressed: () => onPreviewPressed(item['page']),
                );
              },
            ),

            // --- JIKA BUKAN 'GAMBAR TU', TAMPILKAN SISANYA ---
            if (!isGambarTU) ...[
              // 2. Gambar Terurai (Builder agar UI reaktif jika list kosong)
              Builder(
                builder: (context) {
                  // Ambil items terurai yang sudah difilter valid
                  final items = finalPages
                      .where((e) => e['type'] == 'terurai')
                      .toList();

                  // JIKA KOSONG, HIDDEN TOTAL (Sesuai Permintaan)
                  if (items.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: [
                      const Divider(height: 10),
                      _buildSection(
                        title: 'Gambar Terurai',
                        items: items,
                        itemBuilder: (item) => GambarSyncedRow(
                          index: item['index'],
                          title: 'Gambar Terurai',
                          transaksi: transaksi,
                          totalHalaman: totalHalaman,
                          jumlahGambarUtama: jumlahGambarUtama,
                          pageNumber: item['page'], // Halaman dinamis
                          onPreviewPressed: () =>
                              onPreviewPressed(item['page']),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // 3. Gambar Kontruksi
              Builder(
                builder: (context) {
                  final items = finalPages
                      .where((e) => e['type'] == 'kontruksi')
                      .toList();

                  // JIKA KOSONG, HIDDEN TOTAL
                  if (items.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: [
                      const Divider(height: 10),
                      _buildSection(
                        title: 'Gambar Kontruksi',
                        items: items,
                        itemBuilder: (item) => GambarSyncedRow(
                          index: item['index'],
                          title: 'Gambar Kontruksi',
                          transaksi: transaksi,
                          totalHalaman: totalHalaman,
                          jumlahGambarUtama: jumlahGambarUtama,
                          pageNumber: item['page'], // Halaman dinamis
                          onPreviewPressed: () =>
                              onPreviewPressed(item['page']),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // 4. Gambar Optional Paket
              dependentOptionals.when(
                data: (items) {
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      const Divider(height: 10),
                      _buildSectionManual(
                        title: 'Gambar Optional Paket',
                        itemCount: items.length,
                        itemBuilder: (index) {
                          final item = items[index];
                          final pageNumber =
                              startPagePaket + index; // Lanjutkan counter
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
                      const Divider(height: 10),

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
                                'Drag untuk mengatur urutan halaman\nGambar di list atas AKAN DICETAK.\n'
                                'Gambar optional independen bisa disembunyikan\nGambar yang disembunyikan akan muncul di menu "Gambar Disembunyikan".',
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
                            // Hitung halaman: Lanjutkan dari startPageIndependen
                            final pageNumber = startPageIndependen + index;
                            final isPreviewEnabled =
                                ref.watch(pemeriksaIdProvider) != null;
                            final isLoading = ref.watch(isProcessingProvider);

                            // Penomoran Dinamis (Index + 1)
                            final labelNumber = index + 1;

                            return Container(
                              key: ValueKey(item.id),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // --- BAGIAN KIRI: DRAGGABLE ---
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
                                            // 1. Icon Drag
                                            const Icon(
                                              Icons.drag_indicator,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 12),

                                            // 2. Label "Optional Independen X"
                                            SizedBox(
                                              width: 140,
                                              child: Text(
                                                'Optional\nIndependen $labelNumber:',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),

                                            // 3. Nama Item (Dalam Kotak)
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            // 4. Tombol Hide
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
                                            const SizedBox(width: 4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // --- BAGIAN KANAN: STATIS (Nomor & Preview) ---
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
                      // --- MODE READ-ONLY (View) ---
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

                            final labelNumber = index + 1;

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
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 140,
                                            child: Text(
                                              'Optional \nIndependen $labelNumber:',
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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

                      // --- BAGIAN 2: LIST HIDDEN ---
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
                              trailing: Tooltip(
                                message:
                                    'Preview untuk melihat gambar yang disembunyikan\n'
                                    'Pakai untuk menambahkan gambar ke daftar cetak',
                                triggerMode: TooltipTriggerMode.tap,
                                child: Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.lightBlueAccent,
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
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
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
                                                    try {
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
                                                                    'Preview: ${item.name}',
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
              const Divider(height: 10),
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

  // Helper _buildSection Baru (Menerima List Map untuk Logic)
  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required Widget Function(Map<String, dynamic> item) itemBuilder,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

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
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(items[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ],
    );
  }

  // Helper Manual untuk Paket Optional (karena struktur data beda)
  Widget _buildSectionManual({
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
