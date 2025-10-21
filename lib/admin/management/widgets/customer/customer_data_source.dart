import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/management/widgets/customer/edit_customer_dialog.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/customer.dart';
import 'package:master_gambar/data/providers/api_client.dart';

class CustomerDataSource extends DataTableSource {
  final List<Customer> customers;
  final int totalRecords;
  final int rowsPerPage;
  final int currentPage; // Halaman saat ini (1-based)
  final BuildContext context;
  final WidgetRef ref;

  CustomerDataSource({
    required this.customers,
    required this.totalRecords,
    required this.rowsPerPage,
    required this.currentPage,
    required this.context,
    required this.ref,
  });

  @override
  DataRow? getRow(int index) {
    // 'index' adalah index global (0 s/d totalRecords - 1)
    // Kita hitung index lokal untuk list 'customers' di halaman ini
    final int localIndex = index - ((currentPage - 1) * rowsPerPage);

    // Cek apakah index ada di dalam data halaman ini
    if (localIndex < 0 || localIndex >= customers.length) {
      return null;
    }

    final customer = customers[localIndex];
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    final authToken = ref.read(authTokenProvider);

    return DataRow(
      cells: [
        DataCell(SelectableText(customer.namaPt)),
        DataCell(SelectableText(customer.pj)),
        DataCell(
          (customer.signaturePj != null &&
                  customer.signaturePj!.isNotEmpty &&
                  authToken != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Image.network(
                    '${ApiClient.baseUrl}/api/admin/customers/${customer.id}/paraf?v=${customer.updatedAt.millisecondsSinceEpoch}',
                    headers: {'Authorization': 'Bearer $authToken'},
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.orange),
                  ),
                )
              : const Icon(
                  Icons.cancel,
                  color: Colors.red,
                  semanticLabel: 'Tidak Ada',
                ),
        ),
        DataCell(
          SelectableText(dateFormat.format(customer.createdAt.toLocal())),
        ),
        DataCell(
          SelectableText(dateFormat.format(customer.updatedAt.toLocal())),
        ),
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
  int get rowCount => totalRecords; // <-- INI SOLUSINYA

  @override
  int get selectedRowCount => 0;
}
