import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/management/providers/customer_providers.dart';
import 'package:master_gambar/admin/management/widgets/customer/edit_customer_dialog.dart';
import 'package:master_gambar/data/models/customer.dart';

class CustomerDataTable extends ConsumerWidget {
  const CustomerDataTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCustomers = ref.watch(customerListProvider);
    final searchQuery = ref.watch(customerSearchQueryProvider);
    final rowsPerPage = ref.watch(customerRowsPerPageProvider);

    return Card(
      child: asyncCustomers.when(
        data: (customers) {
          final filteredCustomers = customers.where((c) {
            final query = searchQuery.toLowerCase();
            return c.namaPt.toLowerCase().contains(query) ||
                c.pj.toLowerCase().contains(query);
          }).toList();

          return PaginatedDataTable2(
            // fillViewport: true,
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 900, // Sedikit dilebarkan untuk kolom baru
            rowsPerPage: rowsPerPage,
            availableRowsPerPage: const [10, 25, 50, 100],
            onRowsPerPageChanged: (value) {
              if (value != null) {
                ref.read(customerRowsPerPageProvider.notifier).state = value;
              }
            },
            // --- 1. TAMBAHKAN HEADER KOLOM BARU ---
            columns: const [
              DataColumn2(label: Text('Customer'), size: ColumnSize.L),
              DataColumn2(label: Text('Penanggung Jawab'), size: ColumnSize.L),
              DataColumn2(
                label: Text('Paraf'),
                size: ColumnSize.S,
              ), // Kolom baru
              DataColumn2(label: Text('Tanggal Input'), size: ColumnSize.M),
              DataColumn2(label: Text('Terakhir Update'), size: ColumnSize.M),
              DataColumn2(label: Text('Option'), size: ColumnSize.S),
            ],
            source: _CustomerDataSource(filteredCustomers, context, ref),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CustomerDataSource extends DataTableSource {
  final List<Customer> customers;
  final BuildContext context;
  final WidgetRef ref;
  _CustomerDataSource(this.customers, this.context, this.ref);

  @override
  DataRow? getRow(int index) {
    if (index >= customers.length) return null;
    final customer = customers[index];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return DataRow(
      cells: [
        DataCell(Text(customer.namaPt)),
        DataCell(Text(customer.pj)),
        // --- 2. TAMBAHKAN CELL DATA BARU UNTUK PARAF ---
        DataCell(
          Row(
            children: [
              Center(
                child:
                    customer.signaturePj != null &&
                        customer.signaturePj!.isNotEmpty
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        semanticLabel: 'Ada',
                      )
                    : const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        semanticLabel: 'Tidak Ada',
                      ),
              ),
            ],
          ),
        ),
        DataCell(Text(dateFormat.format(customer.createdAt.toLocal()))),
        DataCell(Text(dateFormat.format(customer.updatedAt.toLocal()))),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                tooltip: 'Edit Customer',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => EditCustomerDialog(customer: customer),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => customers.length;
  @override
  int get selectedRowCount => 0;
}
