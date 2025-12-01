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
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10),
              const Text(
                'Manajemen Customer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Customer...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => ref
                      .read(customerNotifierProvider.notifier)
                      .onSearchChanged(value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Muat Ulang Data',
                onPressed: () {
                  ref.read(customerInvalidator.notifier).state++;
                },
              ),
            ],
          ),
          const SizedBox(height: 1),
          const AddCustomerForm(),
          const SizedBox(height: 1),
          const Expanded(child: CustomerDataTable()),
        ],
      ),
    );
  }
}
