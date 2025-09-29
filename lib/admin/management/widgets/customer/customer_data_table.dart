import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/management/providers/customer_providers.dart';
import 'package:master_gambar/admin/management/widgets/customer/edit_customer_dialog.dart';
import 'package:master_gambar/data/models/customer.dart';

class CustomerDataTable extends ConsumerStatefulWidget {
  const CustomerDataTable({super.key});

  @override
  ConsumerState<CustomerDataTable> createState() => _CustomerDataTableState();
}

class _CustomerDataTableState extends ConsumerState<CustomerDataTable> {
  // --- 2. TAMBAHKAN STATE UNTUK SORTING ---
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
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
          // --- 3. TAMBAHKAN BLOK LOGIKA SORTING ---
          final sortedCustomers = List<Customer>.from(filteredCustomers);
          if (_sortColumnIndex != null) {
            sortedCustomers.sort((a, b) {
              late final Comparable<Object> cellA;
              late final Comparable<Object> cellB;
              switch (_sortColumnIndex!) {
                case 0:
                  cellA = a.namaPt.toLowerCase();
                  cellB = b.namaPt.toLowerCase();
                  break;
                case 1:
                  cellA = a.pj.toLowerCase();
                  cellB = b.pj.toLowerCase();
                  break;
                case 3:
                  cellA = a.createdAt;
                  cellB = b.createdAt;
                  break;
                case 4:
                  cellA = a.updatedAt;
                  cellB = b.updatedAt;
                  break;
                default:
                  return 0;
              }
              return _sortAscending
                  ? cellA.compareTo(cellB)
                  : cellB.compareTo(cellA);
            });
          }

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
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: _createColumns(), // Panggil method untuk membuat kolom
            source: _CustomerDataSource(sortedCustomers, context, ref),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // --- 5. BUAT METHOD UNTUK MENGELOLA HEADER KOLOM ---
  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(
        label: const Text('Customer'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Penanggung Jawab'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: Text('Paraf'),
        size: ColumnSize.S,
        // numeric: true,
      ), // Dibuat rata tengah
      DataColumn2(
        label: const Text('Tanggal Input'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Terakhir Update'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      const DataColumn2(label: Text('Option'), size: ColumnSize.S),
    ];
  }

  // --- 6. BUAT METHOD UNTUK MENG-UPDATE STATE SAAT SORT ---
  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
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
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return DataRow(
      cells: [
        DataCell(SelectableText(customer.namaPt)),
        DataCell(SelectableText(customer.pj)),
        DataCell(
          customer.signaturePj != null && customer.signaturePj!.isNotEmpty
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
  int get rowCount => customers.length;
  @override
  int get selectedRowCount => 0;
}
