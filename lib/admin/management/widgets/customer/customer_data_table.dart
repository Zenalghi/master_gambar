import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/customer_providers.dart';
import 'customer_data_source.dart';

class CustomerDataTable extends ConsumerStatefulWidget {
  const CustomerDataTable({super.key});

  @override
  ConsumerState<CustomerDataTable> createState() => _CustomerDataTableState();
}

class _CustomerDataTableState extends ConsumerState<CustomerDataTable> {
  int _rowsPerPage = 50;
  int _currentPage = 1;
  String _sortBy = 'updated_at';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  void _fetchData() {
    final searchQuery = ref.read(customerSearchQueryProvider);
    ref
        .read(customerNotifierProvider.notifier)
        .getCustomers(
          page: _currentPage,
          rowsPerPage: _rowsPerPage,
          sortBy: _sortBy,
          sortAscending: _sortAscending,
          searchQuery: searchQuery,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(customerSearchQueryProvider, (previous, next) {
      if (previous != next) {
        _currentPage = 1;
        _fetchData();
      }
    });

    ref.listen<int>(customerInvalidator, (previous, next) {
      if (previous != next) {
        _fetchData();
      }
    });

    final state = ref.watch(customerNotifierProvider);

    // PERBARUI CARA MEMBUAT DATA SOURCE
    final dataSource = CustomerDataSource(
      customers: state.customers,
      totalRecords: state.totalRecords,
      rowsPerPage: _rowsPerPage,
      currentPage: _currentPage,
      context: context,
      ref: ref,
    );

    return Card(
      child: PaginatedDataTable2(
        headingRowHeight: 36,
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 900,
        rowsPerPage: _rowsPerPage,

        // PERMINTAAN ANDA
        availableRowsPerPage: const [50, 100],

        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() {
              _rowsPerPage = value;
              _currentPage = 1;
            });
            _fetchData();
          }
        },
        sortColumnIndex: _getSortColumnIndex(),
        sortAscending: _sortAscending,

        // HAPUS BARIS INI KARENA INI YANG MENYEBABKAN ERROR
        // total: state.totalRecords,
        initialFirstRowIndex: (_currentPage - 1) * _rowsPerPage,
        onPageChanged: (pageIndex) {
          int newPage = (pageIndex / _rowsPerPage).floor() + 1;
          if (newPage != _currentPage) {
            setState(() {
              _currentPage = newPage;
            });
            _fetchData();
          }
        },
        empty: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : (state.error != null
                  ? Center(child: Text('Error: ${state.error}'))
                  : const Center(child: Text('Tidak ada data'))),
        columns: _createColumns(),
        source: dataSource,
      ),
    );
  }

  // ... (Sisa file _createColumns dan _onSort tidak berubah) ...

  int _getSortColumnIndex() {
    switch (_sortBy) {
      case 'nama_pt':
        return 0;
      case 'pj':
        return 1;
      case 'created_at':
        return 3;
      case 'updated_at':
        return 4;
      default:
        return 0;
    }
  }

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
      const DataColumn2(label: Text('Paraf'), size: ColumnSize.S, onSort: null),
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
      const DataColumn2(
        label: Text('Option'),
        size: ColumnSize.S,
        onSort: null,
      ),
    ];
  }

  void _onSort(int columnIndex, bool ascending) {
    String newSortBy;
    switch (columnIndex) {
      case 0:
        newSortBy = 'nama_pt';
        break;
      case 1:
        newSortBy = 'pj';
        break;
      case 3:
        newSortBy = 'created_at';
        break;
      case 4:
        newSortBy = 'updated_at';
        break;
      default:
        return;
    }
    setState(() {
      _sortBy = newSortBy;
      _sortAscending = ascending;
    });
    _fetchData();
  }
}
