// File: lib/elements/home/screens/input_transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaksi_providers.dart';
import '../widgets/advanced_filter_panel.dart';
// import '../widgets/_tambah_transaksi_forms.dart';
import '../widgets/tambah_transaksi_dialog.dart';
import '../widgets/transaksi_history_table.dart';

class InputTransaksiScreen extends ConsumerWidget {
  const InputTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 1.0, 24.0, 5.0),

      child: Column(
        children: [
          // // Form Tambah Transaksi (tidak berubah)
          // TambahTransaksiForm(
          //   onTransaksiAdded: () {
          //     ref.invalidate(transaksiHistoryProvider);
          //   },
          // ),

          // // const SizedBox(height: 24),
          // SizedBox(height: 16),
          const AdvancedFilterPanel(),
          const SizedBox(height: 16),
          // --- TAMBAHAN BARU: BARIS KONTROL TABEL ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bagian kiri tetap sama
              const Text(
                "Histori Transaksi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('TAMBAH TRANSAKSI'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ), // Padding agar tombol lebih besar
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    // Panggil dialog baru saat tombol ditekan
                    builder: (context) => TambahTransaksiDialog(
                      onTransaksiAdded: () {
                        // Callback untuk me-refresh tabel
                        ref.invalidate(transaksiHistoryProvider);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),

              // Bagian kanan sekarang berisi Search dan Reload
              Row(
                children: [
                  // Search Field Global
                  SizedBox(
                    width: 250, // Beri lebar agar tidak terlalu besar
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        isDense: true, // Membuatnya lebih ringkas
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        // Update provider saat pengguna mengetik
                        ref.read(globalSearchQueryProvider.notifier).state =
                            value;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tombol Reload
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reload Data',
                    onPressed: () {
                      ref.invalidate(transaksiHistoryProvider);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8), // Sedikit spasi
          // --- AKHIR TAMBAHAN BARU ---
          Expanded(
            child: Card(
              child: SizedBox(
                width: double.infinity,
                child: TransaksiHistoryTable(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
