import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/customer_providers.dart';
import 'package:master_gambar/admin/management/widgets/customer/add_customer_form.dart';
import 'package:master_gambar/admin/management/widgets/customer/customer_data_table.dart';

class CustomerManagementScreen extends ConsumerWidget {
  const CustomerManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Bagian Atas: Form Tambah & Kontrol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manajemen Customer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Customer...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) =>
                      ref.read(customerSearchQueryProvider.notifier).state =
                          value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AddCustomerForm(),
          const SizedBox(height: 24),

          // Bagian Bawah: Tabel
          const Expanded(child: CustomerDataTable()),
        ],
      ),
    );
  }
}
