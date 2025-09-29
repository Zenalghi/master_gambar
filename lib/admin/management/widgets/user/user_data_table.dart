import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:master_gambar/admin/management/providers/user_providers.dart';
import 'package:master_gambar/admin/management/widgets/user/edit_user_dialog.dart';
import 'package:master_gambar/data/models/app_user.dart';

class UserDataTable extends ConsumerStatefulWidget {
  const UserDataTable({super.key});

  @override
  ConsumerState<UserDataTable> createState() => _UserDataTableState();
}

class _UserDataTableState extends ConsumerState<UserDataTable> {
  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final asyncUsers = ref.watch(userListProvider);
    final searchQuery = ref.watch(userSearchQueryProvider);
    final rowsPerPage = ref.watch(userRowsPerPageProvider);

    return Card(
      child: asyncUsers.when(
        data: (users) {
          final filteredUsers = users.where((u) {
            final query = searchQuery.toLowerCase();
            return u.name.toLowerCase().contains(query) ||
                u.username.toLowerCase().contains(query);
          }).toList();

          final sortedUsers = List<AppUser>.from(filteredUsers);
          sortedUsers.sort((a, b) {
            int result = 0;
            switch (_sortColumnIndex) {
              case 0:
                result = a.name.compareTo(b.name);
                break;
              case 1:
                result = a.username.compareTo(b.username);
                break;
              case 2:
                result = (a.role?.name ?? '').compareTo(b.role?.name ?? '');
                break;
              case 4:
                result = a.createdAt.compareTo(b.createdAt);
                break;
              case 5:
                result = a.updatedAt.compareTo(b.updatedAt);
                break;
            }
            return _sortAscending ? result : -result;
          });

          return PaginatedDataTable2(
            // fillViewport: true,
            minWidth: 900,
            rowsPerPage: rowsPerPage,
            availableRowsPerPage: const [10, 25, 50, 100],
            onRowsPerPageChanged: (value) =>
                ref.read(userRowsPerPageProvider.notifier).state = value!,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: _createColumns(),
            source: _UserDataDataSource(sortedUsers, context, ref),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
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
      DataColumn2(label: Text('Paraf'), size: ColumnSize.S),
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

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}

class _UserDataDataSource extends DataTableSource {
  final List<AppUser> users;
  final BuildContext context;
  final WidgetRef ref;
  _UserDataDataSource(this.users, this.context, this.ref);

  @override
  DataRow? getRow(int index) {
    final user = users[index];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return DataRow(
      cells: [
        DataCell(SelectableText(user.name)),
        DataCell(SelectableText(user.username)),
        DataCell(Text(user.role?.name ?? 'N/A')),
        DataCell(
          user.signature != null
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.cancel, color: Colors.red),
        ),
        DataCell(SelectableText(dateFormat.format(user.createdAt.toLocal()))),
        DataCell(SelectableText(dateFormat.format(user.updatedAt.toLocal()))),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => EditUserDialog(user: user),
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
  int get rowCount => users.length;
  @override
  int get selectedRowCount => 0;
}
