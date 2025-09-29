import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/data/models/transaksi.dart';
import 'package:master_gambar/elements/home/providers/input_gambar_providers.dart';

class GambarHeaderInfo extends ConsumerWidget {
  final Transaksi transaksi;
  final int jumlahGambar;

  const GambarHeaderInfo({
    super.key,
    required this.transaksi,
    required this.jumlahGambar,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- BARIS PERTAMA ---
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
            // --- BARIS KEDUA ---
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
                // Kolom terakhir berisi 2 dropdown
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildJumlahGambarInfo()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPemeriksaDropdown(ref)),
                        ],
                      ),
                      // Menambahkan spasi kosong agar tingginya sama dengan field info
                      const SizedBox(height: 25),
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
  Widget _buildJumlahGambarInfo() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Jumlah Gbr. Utama',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        jumlahGambar.toString(),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPemeriksaDropdown(WidgetRef ref) {
    final pemeriksaOptions = ref.watch(pemeriksaOptionsProvider);
    final selectedId = ref.watch(pemeriksaIdProvider);

    return pemeriksaOptions.when(
      data: (items) => DropdownButtonFormField<int>(
        value: selectedId,
        hint: const Text('Pemeriksa'), // Gunakan hintText
        decoration: const InputDecoration(
          // Hapus labelText
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ), // Atur padding
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<int>(
                value: e.id as int,
                child: Text(e.name),
              ),
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
}
