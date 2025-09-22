// File: lib/elements/home/screens/input_transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaksi_providers.dart';
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
            const SizedBox(height: 24),

            // --- TAMBAHAN BARU: BARIS KONTROL TABEL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Di sini nanti kita letakkan "Show entries" (untuk langkah berikutnya)
                const Text("Histori Transaksi"),

                // Tombol Reload
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reload Data',
                  onPressed: () {
                    // Sama seperti callback, kita invalidate provider
                    // untuk memaksa tabel memuat ulang data.
                    ref.invalidate(transaksiHistoryProvider);
                  },
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
