// File: lib/elements/home/screens/input_transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider untuk data dropdown (contoh untuk Customer)
final customerOptionsProvider = FutureProvider<List<dynamic>>((ref) async {
  // Panggil API Laravel Anda di sini
  // final response = await ref.read(apiClientProvider).dio.get('/options/customers');
  // return response.data;
  // --- Data Dummy untuk sekarang ---
  await Future.delayed(const Duration(seconds: 1)); // simulasi loading
  return [
    {'id': 1, 'nama_pt': 'CV SURYA INDAH PRATAMA'},
    {'id': 2, 'nama_pt': 'PT ADI JAYA'},
  ];
});

class InputTransaksiScreen extends ConsumerWidget {
  const InputTransaksiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerOptions = ref.watch(customerOptionsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kontainer Atas (Dropdown)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Contoh Dropdown untuk Customer
                    customerOptions.when(
                      data: (customers) => DropdownButtonFormField(
                        items: customers.map((customer) {
                          return DropdownMenuItem(
                            value: customer['id'],
                            child: Text(customer['nama_pt']),
                          );
                        }).toList(),
                        onChanged: (value) {},
                        decoration: const InputDecoration(labelText: 'Customer'),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => const Text('Gagal memuat data customer'),
                    ),

                    // TODO: Buat dropdown lain dengan pola yang sama (Type Engine, Merk, dll)

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Input Gambar'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Kontainer Bawah (Tabel) - Placeholder
            const Card(
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: Center(
                  child: Text('Tabel Data Transaksi akan ditampilkan di sini'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}