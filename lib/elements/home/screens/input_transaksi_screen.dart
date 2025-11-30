import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaksi_providers.dart';
import '../widgets/advanced_filter_panel.dart';
import '../widgets/tambah_transaksi_dialog.dart';
import '../widgets/transaksi_history_table.dart';

// Ubah menjadi ConsumerStatefulWidget agar bisa pakai initState
class InputTransaksiScreen extends ConsumerStatefulWidget {
  const InputTransaksiScreen({super.key});

  @override
  ConsumerState<InputTransaksiScreen> createState() =>
      _InputTransaksiScreenState();
}

class _InputTransaksiScreenState extends ConsumerState<InputTransaksiScreen> {
  @override
  void initState() {
    super.initState();
    // Reset filter saat halaman dibuka agar pencarian lama hilang
    Future.microtask(() {
      ref.invalidate(transaksiFilterProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 0),
      child: Column(
        children: [
          // 1. Filter Lanjutan
          const AdvancedFilterPanel(),
          const SizedBox(height: 8),

          // 2. Baris Kontrol (Judul, Tombol Tambah, Search, Refresh)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 12),
              const Text(
                "Histori Transaksi",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              // Tombol Tambah Transaksi
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  'TAMBAH TRANSAKSI',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => TambahTransaksiDialog(
                      onTransaksiAdded: () {
                        // Refresh tabel setelah berhasil tambah
                        // Kita update state provider untuk memicu listener di DataSource
                        ref
                            .read(transaksiFilterProvider.notifier)
                            .update((state) => Map.from(state));
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),

              // Search Field & Reload
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    height: 31,
                    child: TextField(
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 11),
                        labelText: 'Search Global...',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        // Update provider 'search' saat mengetik
                        ref
                            .read(transaksiFilterProvider.notifier)
                            .update((state) => {...state, 'search': value});
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Tombol Reload Manual
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Reload Data',
                    onPressed: () {
                      // Paksa refresh dengan mengupdate state map baru
                      ref
                          .read(transaksiFilterProvider.notifier)
                          .update((state) => Map.from(state));
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3. Tabel Histori
          const Expanded(
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
