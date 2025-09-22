// File: lib/elements/home/screens/input_transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaksi_providers.dart';
import '../widgets/tambah_transaksi_form.dart'; // 1. Import widget form baru
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
            // 2. Panggil widget form di sini
            TambahTransaksiForm(
              // 3. Berikan aksi yang harus dilakukan setelah transaksi berhasil
              onTransaksiAdded: () {
                ref.invalidate(transaksiHistoryProvider);
              },
            ),
            const SizedBox(height: 24),
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
