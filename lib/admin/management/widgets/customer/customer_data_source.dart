// lib/admin/management/widgets/customer/customer_data_source.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/management/widgets/customer/edit_customer_dialog.dart';
import 'package:master_gambar/app/core/providers.dart';
import 'package:master_gambar/data/models/customer.dart';

class CustomerDataSource extends DataTableSource {
  final List<Customer> customers;
  final int totalRecords;
  final int rowsPerPage;
  final int currentPage;
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
    final int localIndex = index - ((currentPage - 1) * rowsPerPage);

    if (localIndex < 0 || localIndex >= customers.length) {
      return null;
    }

    final customer = customers[localIndex];
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    final authToken = ref.read(authTokenProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Ambil base URL dari instance Dio yang aktif
    final baseUrl = ref.read(apiClientProvider).dio.options.baseUrl;

    return DataRow(
      cells: [
        DataCell(SelectableText(customer.namaPt)),
        DataCell(SelectableText(customer.pj)),
        DataCell(SelectableText(customer.namaDrafter ?? '-')),
        DataCell(SelectableText(customer.namaPemeriksa ?? '-')),
        DataCell(
          (customer.signaturePj != null &&
                  customer.signaturePj!.isNotEmpty &&
                  authToken != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Image.network(
                    '$baseUrl/admin/customers/${customer.id}/paraf?v=${customer.updatedAt.millisecondsSinceEpoch}',
                    headers: {'Authorization': 'Bearer $authToken'},
                    fit: BoxFit.contain,
                    color: colorScheme.onSurface,
                    colorBlendMode: BlendMode.srcIn,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                    // Tambahkan Tooltip di sini
                    errorBuilder: (context, error, stackTrace) => Tooltip(
                      message: 'Error: ${error.toString()}',
                      child: Icon(Icons.error, color: colorScheme.error),
                    ),
                  ),
                )
              : const Icon(
                  Icons.cancel,
                  size: 15,
                  color: Colors.red,
                  semanticLabel: 'Tidak Ada',
                ),
        ),
        DataCell(
          (customer.signatureDrafter != null &&
                  customer.signatureDrafter!.isNotEmpty &&
                  authToken != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Image.network(
                    '$baseUrl/admin/customers/${customer.id}/paraf-drafter?v=${customer.updatedAt.millisecondsSinceEpoch}',
                    headers: {'Authorization': 'Bearer $authToken'},
                    fit: BoxFit.contain,
                    color: colorScheme.onSurface,
                    colorBlendMode: BlendMode.srcIn,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                    // Tambahkan Tooltip di sini
                    errorBuilder: (context, error, stackTrace) => Tooltip(
                      message: 'Error: ${error.toString()}',
                      child: Icon(Icons.error, color: colorScheme.error),
                    ),
                  ),
                )
              : const Icon(
                  Icons.cancel,
                  size: 15,
                  color: Colors.red,
                  semanticLabel: 'Tidak Ada',
                ),
        ),
        DataCell(
          (customer.signaturePemeriksa != null &&
                  customer.signaturePemeriksa!.isNotEmpty &&
                  authToken != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Image.network(
                    '$baseUrl/admin/customers/${customer.id}/paraf-pemeriksa?v=${customer.updatedAt.millisecondsSinceEpoch}',
                    headers: {'Authorization': 'Bearer $authToken'},
                    fit: BoxFit.contain,
                    color: colorScheme.onSurface,
                    colorBlendMode: BlendMode.srcIn,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                    errorBuilder: (context, error, stackTrace) => Tooltip(
                      message: 'Error: ${error.toString()}',
                      child: Icon(Icons.error, color: colorScheme.error),
                    ),
                  ),
                )
              : const Icon(
                  Icons.cancel,
                  size: 15,
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
                icon: const Icon(Icons.edit, color: Colors.orange, size: 15),
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
  int get rowCount => totalRecords;

  @override
  int get selectedRowCount => 0;
}
