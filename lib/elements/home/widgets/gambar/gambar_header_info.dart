import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';
import '../../../../app/core/notifiers/refresh_notifier.dart';

class GambarHeaderInfo extends ConsumerWidget {
  final Transaksi transaksi;

  const GambarHeaderInfo({super.key, required this.transaksi});
  // --- BUAT METHOD BARU UNTUK LOGIKA REFRESH ---
  void _resetAndRefresh(BuildContext context, WidgetRef ref) {
    // 1. Reset semua state pilihan di form
    ref.read(pemeriksaIdProvider.notifier).state = null;
    ref.read(jumlahGambarProvider.notifier).state = 1;
    // invalidate akan mereset StateNotifier ke state awalnya
    ref.invalidate(gambarUtamaSelectionProvider);

    // 2. Tutup dan reset checkbox beserta isinya
    ref.read(showGambarOptionalProvider.notifier).state = false;
    ref.read(jumlahGambarOptionalProvider.notifier).state = 1;
    ref.invalidate(gambarOptionalSelectionProvider);

    ref.read(showGambarKelistrikanProvider.notifier).state = false;
    ref.read(gambarKelistrikanIdProvider.notifier).state = null;

    // 3. Bunyikan "lonceng" untuk memicu FutureProvider mengambil data baru
    ref.read(refreshNotifierProvider.notifier).refresh();

    // 4. Beri feedback ke pengguna
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memuat ulang data pilihan...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- BARIS PERTAMA (Tidak berubah) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoField('No. ID', transaksi.id),
                const SizedBox(width: 16),
                _buildInfoField(
                  'Type Engine',
                  transaksi.aTypeEngine.typeEngine,
                ),
                const SizedBox(width: 16),
                _buildInfoField('Merk', transaksi.bMerk.merk),
                const SizedBox(width: 16),
                _buildInfoField(
                  'Type Chassis',
                  transaksi.cTypeChassis.typeChassis,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // --- BARIS KEDUA (Ada perubahan) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoField('Customer', transaksi.customer.namaPt),
                const SizedBox(width: 16),
                _buildInfoField(
                  'Jenis Kendaraan',
                  transaksi.dJenisKendaraan.jenisKendaraan,
                ),
                const SizedBox(width: 16),
                _buildInfoField(
                  'Jenis Pengajuan',
                  transaksi.fPengajuan.jenisPengajuan,
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildJumlahGambarDropdown(ref)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPemeriksaDropdown(ref)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Muat Ulang Pilihan',
                        onPressed: () => _resetAndRefresh(context, ref),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper ini diubah untuk menampilkan label di atas field
  Widget _buildInfoField(String label, String value) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  // Dropdown ini diubah agar tidak memiliki label eksplisit untuk tampilan yang lebih bersih
  Widget _buildJumlahGambarDropdown(WidgetRef ref) {
    // Tonton provider untuk mendapatkan nilai yang sedang dipilih
    final selectedJumlah = ref.watch(jumlahGambarProvider);

    // Buat daftar opsi statis dari 1 sampai 4
    final options = [1, 2, 3, 4];

    return DropdownButtonFormField<int>(
      value: selectedJumlah,
      decoration: const InputDecoration(
        labelText: 'Jumlah Gbr',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
      items: options
          .map(
            (e) => DropdownMenuItem<int>(value: e, child: Text(e.toString())),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          // Update provider saat nilai diubah
          ref.read(jumlahGambarProvider.notifier).state = value;
        }
      },
    );
  }
}

Widget _buildPemeriksaDropdown(WidgetRef ref) {
  final pemeriksaOptions = ref.watch(pemeriksaOptionsProvider);
  final selectedId = ref.watch(pemeriksaIdProvider);

  return pemeriksaOptions.when(
    data: (items) => DropdownButtonFormField<int>(
      initialValue: selectedId,
      hint: const Text('Pemeriksa'),
      decoration: const InputDecoration(
        labelText: 'Pemeriksa',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ), // Atur padding
      ),
      items: items
          .map(
            (e) =>
                DropdownMenuItem<int>(value: e.id as int, child: Text(e.name)),
          )
          .toList(),
      onChanged: (value) {
        ref.read(pemeriksaIdProvider.notifier).state = value;
      },
    ),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) =>
        const Tooltip(message: 'Error', child: Icon(Icons.error)),
  );
}
