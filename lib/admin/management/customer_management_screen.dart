import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/customer_providers.dart';
import 'widgets/customer/add_customer_form.dart';
import 'widgets/customer/customer_data_table.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends ConsumerState<CustomerManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshCustomers() {
    _searchController.clear();
    ref.read(customerSearchQueryProvider.notifier).state = '';
    ref.read(customerInvalidator.notifier).state++;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 10),
              const Text(
                'Manajemen Customer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 31,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(fontSize: 14),
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
                onPressed: _refreshCustomers,
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
