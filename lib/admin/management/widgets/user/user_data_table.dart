import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/management/providers/user_providers.dart';
import 'user_data_source.dart';

class UserDataTable extends ConsumerStatefulWidget {
  const UserDataTable({super.key});

  @override
  ConsumerState<UserDataTable> createState() => _UserDataTableState();
}

class _UserDataTableState extends ConsumerState<UserDataTable> {
  int _rowsPerPage = 50; // Ubah default ke 50
  int _currentPage = 1;
  String _sortBy = 'updated_at';
  bool _sortAscending = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData({bool showLoading = false}) async {
    final searchQuery = ref.read(userSearchQueryProvider);

    if (showLoading) {
      setState(() => _isRefreshing = true);
    }

    final start = DateTime.now();
    await ref
        .read(userNotifierProvider.notifier)
        .getUsers(
          page: _currentPage,
          rowsPerPage: _rowsPerPage,
          sortBy: _sortBy,
          sortAscending: _sortAscending,
          searchQuery: searchQuery,
        );

    if (showLoading) {
      final elapsed = DateTime.now().difference(start);
      final remaining = const Duration(milliseconds: 500) - elapsed;
      if (remaining.isNegative) {
        if (mounted) {
          setState(() => _isRefreshing = false);
        }
        return;
      }

      await Future.delayed(remaining);
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(userSearchQueryProvider, (previous, next) {
      if (previous != next) {
        _currentPage = 1;
        _fetchData();
      }
    });

    ref.listen<int>(userInvalidator, (previous, next) {
      if (previous != next) {
        _fetchData(showLoading: true);
      }
    });

    final state = ref.watch(userNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // PERBARUI CARA MEMBUAT DATA SOURCE
    final dataSource = UserDataSource(
      users: state.users,
      totalRecords: state.totalRecords,
      rowsPerPage: _rowsPerPage,
      currentPage: _currentPage,
      context: context,
      ref: ref,
    );

    return Stack(
      children: [
        Card(
          color: colorScheme.surface,
          child: PaginatedDataTable2(
            headingRowHeight: 36,
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
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : (state.error != null
                      ? Center(child: Text('Error: ${state.error}'))
                      : const Center(child: Text('Tidak ada data'))),
            columns: _createColumns(),
            source: dataSource,
          ),
        ),
        if (_isRefreshing)
          Positioned.fill(
            child: ColoredBox(
              color: colorScheme.surface.withValues(alpha: 0.88),
              child: Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }

  // ... (Sisa file _createColumns dan _onSort tidak berubah) ...

  int _getSortColumnIndex() {
    switch (_sortBy) {
      case 'name':
        return 0;
      case 'username':
        return 1;
      case 'role':
        return 2;
      case 'hint':
        return 3; // <-- TAMBAHKAN INI
      case 'created_at':
        return 5; // <-- Ubah jadi 5
      case 'updated_at':
        return 6; // <-- Ubah jadi 6
      default:
        return 0;
    }
  }

  List<DataColumn2> _createColumns() {
    return [
      DataColumn2(
        label: const Text('Nama'),
        size: ColumnSize.L,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Username'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Role'),
        size: ColumnSize.S,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Hint'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      const DataColumn2(label: Text('Paraf'), size: ColumnSize.S, onSort: null),
      DataColumn2(
        label: const Text('Created At'),
        size: ColumnSize.M,
        onSort: _onSort,
      ),
      DataColumn2(
        label: const Text('Updated At'),
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
        newSortBy = 'name';
        break;
      case 1:
        newSortBy = 'username';
        break;
      case 2:
        newSortBy = 'role';
        break;
      case 3:
        newSortBy = 'hint';
        break; // <-- TAMBAHKAN INI
      case 5:
        newSortBy = 'created_at';
        break; // <-- Ubah jadi 5
      case 6:
        newSortBy = 'updated_at';
        break; // <-- Ubah jadi 6
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
