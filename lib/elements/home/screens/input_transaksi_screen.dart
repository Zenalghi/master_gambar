// File: lib/elements/home/screens/input_transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaksi_providers.dart';
import '../widgets/advanced_filter_panel.dart';
import '../widgets/tambah_transaksi_form.dart';
import '../widgets/transaksi_history_table.dart';

class InputTransaksiScreen extends ConsumerWidget {
  const InputTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Form Tambah Transaksi (tidak berubah)
            TambahTransaksiForm(
              onTransaksiAdded: () {
                ref.invalidate(transaksiHistoryProvider);
              },
            ),
            
            // const SizedBox(height: 24),
            SizedBox(height: 16),
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
                    const SizedBox(width: 8),
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
      ),
    );
  }
}
